#!/bin/bash
hciconfig hci0 up
hciconfig hci0 piscan
hciconfig hci0 sspmode 1
