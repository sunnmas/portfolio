#ifndef DEFINES_H
#define DEFINES_H

//Симулировать камеру:
//true - передает готовое изображение из файла test.jpg
//false - использует реальную камеру
#define SIMULATE_CAMERA false
//IP адрес планшета и порт программы на планшете
// #define UDP_RECEIVER_IP "192.168.0.4"
#define UDP_PORT 22125
//Размер пакета в байтах
#define UDP_DATAGRAM_SIZE 1132
//Пауза мкс после посылки пакета
#define UDP_PAUSE_AFTER_DTGR_TRANSMIT_uS 10
#define FRAME_BUFFER_LENGTH 4 //менять нельзя
//Качество jpg картинки
#define FRAME_JPG_QUALITY 60
#define FRAME_WIDTH 640
#define FRAME_HEIGHT 480
#define FRAME_RATE 30
//Joystick port
#define JOYSTICK_PORT 22126

#define UINT_SIZE sizeof(unsigned int)

#endif // DEFINES_H