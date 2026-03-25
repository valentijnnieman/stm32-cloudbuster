#include <alsa/asoundlib.h>
#include <fcntl.h>
#include <linux/input.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define ADC_PATH "/sys/bus/iio/devices/iio:device1/in_voltage6_raw"
#define INPUT_PATH "/dev/input/event1"
#define MIDI_CC_NEXT 48
#define MIDI_CC_PREV 47
#define MIDI_CC_POT 7

snd_seq_t *seq;
int port;

void midi_init() {
  snd_seq_open(&seq, "default", SND_SEQ_OPEN_OUTPUT, 0);
  snd_seq_set_client_name(seq, "stm32-controls");
  port = snd_seq_create_simple_port(
      seq, "controls", SND_SEQ_PORT_CAP_READ | SND_SEQ_PORT_CAP_SUBS_READ,
      SND_SEQ_PORT_TYPE_MIDI_GENERIC);
}

void midi_send_cc(int cc, int value) {
  // printf("CC %d = %d\n", cc, value);
  snd_seq_event_t ev;
  snd_seq_ev_clear(&ev);
  snd_seq_ev_set_direct(&ev);
  snd_seq_ev_set_subs(&ev);
  snd_seq_ev_set_controller(&ev, 0, cc, value);
  snd_seq_event_output_direct(seq, &ev);
}

int read_adc() {
  FILE *f = fopen(ADC_PATH, "r");
  if (!f)
    return -1;
  int val;
  fscanf(f, "%d", &val);
  fclose(f);
  return val;
}

int main() {
  midi_init();

  // Open input device for buttons
  int fd = open(INPUT_PATH, O_RDONLY);
  if (fd < 0) {
    perror("Failed to open input device");
    return 1;
  }

  int last_adc = -1;
  struct input_event ev;

  printf("stm32-controls started\n");

  while (1) {
    // Check ADC — non-blocking using select
    fd_set fds;
    struct timeval tv = {0, 10000}; // 10ms timeout
    FD_ZERO(&fds);
    FD_SET(fd, &fds);

    if (select(fd + 1, &fds, NULL, NULL, &tv) > 0) {
      if (read(fd, &ev, sizeof(ev)) == sizeof(ev)) {
        if (ev.type == EV_KEY && ev.value == 1) {
          if (ev.code == KEY_NEXT) {
            printf("Button next\n");
            midi_send_cc(MIDI_CC_NEXT, 127);
          }
          if (ev.code == KEY_PREVIOUS) {
            printf("Button prev\n");
            midi_send_cc(MIDI_CC_PREV, 127);
          }
        }
      }
    }

    // Read potentiometer
    int raw = read_adc();
    if (raw >= 0) {
      int cc_val = raw * 127 / 65535;
      if (abs(cc_val - last_adc) > 1) {
        midi_send_cc(MIDI_CC_POT, cc_val);
        last_adc = cc_val;
      }
    }
  }

  snd_seq_close(seq);
  return 0;
}
