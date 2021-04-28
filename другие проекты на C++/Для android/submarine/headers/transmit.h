#ifndef TRANSMIT_H
#define TRANSMIT_H

#include <cmath>
#include <unistd.h>
#include <time.h>
#include <string.h> 
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <cstring>
#include <iostream>
#include <fstream>
#include "../defines.h"
#include "../headers/camera.h"
#include "../headers/telemetry.h"

class Transmitter
{
public:
    explicit Transmitter();
    virtual ~Transmitter();
	void transmit_frame(Frame *frame, TelemetryStruct *telemetry);
private:
	int sockfd; //UDP сокет
	struct sockaddr_in servaddr; //ip адрес приемника
	char *datagram[UDP_DATAGRAM_SIZE];
	unsigned long frame_number = 0;
};


#endif //TRANSMIT_H