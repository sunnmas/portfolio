#include "../headers/gamepad.h"

Gamepad::Gamepad()
{
    // Creating socket file descriptor 
    if ( (sockfd = socket(AF_INET, SOCK_DGRAM, 0)) < 0 ) { 
        perror("socket creation failed"); 
        exit(EXIT_FAILURE); 
    }

    memset(&servaddr, 0, sizeof(servaddr)); 
    memset(&cliaddr, 0, sizeof(cliaddr)); 

    servaddr.sin_family    = AF_INET; // IPv4 
    servaddr.sin_addr.s_addr = INADDR_ANY; 
    servaddr.sin_port = htons(JOYSTICK_PORT);

    // Bind the socket with the server address 
    if ( bind(sockfd, (const struct sockaddr *)&servaddr,  
            sizeof(servaddr)) < 0 ) 
    { 
        perror("bind failed"); 
        exit(EXIT_FAILURE); 
    } 
}

Gamepad::~Gamepad()
{
    close(sockfd);
}

void Gamepad::receive() {
    unsigned int len, n; 
  
    len = sizeof(cliaddr);  //len is value/resuslt 
  
    n = recvfrom(sockfd, (char *)buffer, sizeof(GamepadState),  
                MSG_WAITALL, ( struct sockaddr *) &cliaddr, 
                &len); 
    buffer[n] = '\0';


    memcpy(&state, buffer, sizeof(GamepadState));
    if (prevState.A != state.A ||
        prevState.B != state.B ||
        prevState.START != state.START ||
        prevState.L1 != state.L1 ||
        prevState.R1 != state.R1 ||
        prevState.L3 != state.L3 ||
        prevState.UP != state.UP ||
        prevState.DOWN != state.DOWN ||
        prevState.LEFT != state.LEFT ||
        prevState.RIGHT != state.RIGHT ||
        prevState.W != state.W ||
        prevState.X != state.X ||
        prevState.Y != state.Y ||
        prevState.Z != state.Z)
    {
        printState();
        prevState = state;
    }
}

GamepadState Gamepad::getState() {
    return state;
}

void Gamepad::printState() {
    system("clear");
    printf("A: %s\n", state.A ? "true": "false");
    printf("B: %s\n", state.B ? "true": "false");
    printf("START: %s\n", state.START ? "true": "false");
    printf("L1: %s\n", state.L1 ? "true": "false");
    printf("R1: %s\n", state.R1 ? "true": "false");
    printf("L3: %s\n", state.L3 ? "true": "false");
    printf("UP: %s\n", state.UP ? "true": "false");
    printf("DOWN: %s\n", state.DOWN ? "true": "false");
    printf("LEFT: %s\n", state.LEFT ? "true": "false");
    printf("RIGHT: %s\n", state.RIGHT ? "true": "false");
    printf("W: %f\n", state.W);
    printf("X: %f\n", state.X);
    printf("Y: %f\n", state.Y);
    printf("Z: %f\n", state.Z);
}
