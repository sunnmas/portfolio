#ifndef GAMEPAD_H
#define GAMEPAD_H

#include <stdio.h> 
#include <stdlib.h> 
#include <unistd.h> 
#include <string.h> 
#include <sys/types.h> 
#include <sys/socket.h> 
#include <arpa/inet.h> 
#include <netinet/in.h>
#include "../defines.h"

struct GamepadState {
    double W = 0.0;
    double X = 0.0;
    double Y = 0.0;
    double Z = 0.0;
    bool A = false;
    bool B = false;
    bool START = false;
    bool L1 = false;
    bool R1 = false;
    bool L3 = false;
    bool UP = false;
    bool DOWN = false;
    bool LEFT = false;
    bool RIGHT = false;
};

class Gamepad
{
public:
    explicit Gamepad();
    virtual ~Gamepad();
    GamepadState getState();
    void receive();
private:
    int sockfd;
    struct sockaddr_in servaddr, cliaddr;
    char buffer[sizeof(GamepadState)]; 
    GamepadState prevState;
    GamepadState state;
    void printState();
};

#endif // GAMEPAD_H