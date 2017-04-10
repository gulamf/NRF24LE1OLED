CC         := sdcc --verbose
PACKIHX    := packihx
HEX2IMAGE  := hex2image
PROGRAMMER := nrf24le1flash
MONITOR    += gtkterm


CFLAGS     := --opt-code-speed --model-large
LFLAGS     := --code-loc 0x0000 --code-size 0x4000 --xram-loc 0x0000 --xram-size 0x400
FLASH_SIZE := 16384
MAIN       := main
BIN        := main.img
PORT 	   := /dev/ttyUSB0

SDK_DIR            := $(shell cd /opt/nrf24le1_sdk_v4.0 && pwd)
INCLUDE            += -I $(SDK_DIR)/include
REL_EXTERNAL_DIR   := $(SDK_DIR)/_target_sdcc_nrf24le1/obj
REL_EXTERNAL_FILES += $(REL_EXTERNAL_DIR)/delay/delay_ms.rel
REL_EXTERNAL_FILES += $(REL_EXTERNAL_DIR)/delay/delay_s.rel
REL_EXTERNAL_FILES += $(REL_EXTERNAL_DIR)/delay/delay_us.rel
REL_EXTERNAL_FILES += $(REL_EXTERNAL_DIR)/pwr_clk_mgmt/pwr_clk_mgmt_cclk_configure.rel
REL_EXTERNAL_FILES += $(REL_EXTERNAL_DIR)/timer1/timer1_configure.rel
REL_EXTERNAL_FILES += $(REL_EXTERNAL_DIR)/uart/uart_configure_manual_baud_calc.rel
REL_EXTERNAL_FILES += $(REL_EXTERNAL_DIR)/uart/uart_send_wait_for_complete.rel
REL_EXTERNAL_FILES += $(REL_EXTERNAL_DIR)/uart/uart_wait_for_rx_and_get.rel
REL_EXTERNAL_FILES += $(REL_EXTERNAL_DIR)/w2/w2_configure.rel
REL_EXTERNAL_FILES += $(REL_EXTERNAL_DIR)/w2/w2_master_cur_address_read.rel
REL_EXTERNAL_FILES += $(REL_EXTERNAL_DIR)/w2/w2_master_process_start_request.rel
REL_EXTERNAL_FILES += $(REL_EXTERNAL_DIR)/w2/w2_master_process_stop_request.rel
REL_EXTERNAL_FILES += $(REL_EXTERNAL_DIR)/w2/w2_master_random_address_read.rel
REL_EXTERNAL_FILES += $(REL_EXTERNAL_DIR)/w2/w2_master_rx_byte.rel
REL_EXTERNAL_FILES += $(REL_EXTERNAL_DIR)/w2/w2_master_software_reset.rel
REL_EXTERNAL_FILES += $(REL_EXTERNAL_DIR)/w2/w2_master_tx_byte.rel
REL_EXTERNAL_FILES += $(REL_EXTERNAL_DIR)/w2/w2_master_write_control_bytes.rel
REL_EXTERNAL_FILES += $(REL_EXTERNAL_DIR)/w2/w2_master_write_to.rel
REL_EXTERNAL_FILES += $(REL_EXTERNAL_DIR)/w2/w2_wait_for_byte_tx_or_rx.rel


REL_SRC := $(MAIN).c
REL_OBJ := $(patsubst %.c,%.rel,$(REL_SRC))


all: rel build

%.rel: %.c
	$(CC) -c $(INCLUDE) $(CFLAGS) $(LFLAGS) $<

rel: $(REL_OBJ)

build:
	$(CC) $(CFLAGS) $(LDFLAGS) $(REL_OBJ) $(REL_EXTERNAL_FILES)
	$(PACKIHX) $(MAIN).ihx > $(MAIN).hex
	$(HEX2IMAGE) -S $(FLASH_SIZE) < $(MAIN).hex > $(BIN)
	tail -n5 $(MAIN).mem

clean:
	$(RM) *.asm *.cdb *.hex *.ihx *.lk *.lst *.map *.mem *.omf *.rel *.rst *.sym *.img


test: all burn monitor

burn: rel build
	$(PROGRAMMER) -f $(MAIN).hex -p $(PORT) -c FLASH

monitor:
	$(MONITOR) -p $(PORT) -s 38400
