#include "../headers/transmit.h"
using namespace std;

Transmitter::Transmitter() {
    //Читаем из файла айпишник планшета:
    char UDP_RECEIVER_IP[16];
    ifstream file("./ip");
    file.getline(UDP_RECEIVER_IP, 16);
    file.close();

    memset(&servaddr, 0, sizeof(servaddr)); 
    if ( (sockfd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0 ) { 
        perror("socket creation failed"); 
        exit(EXIT_FAILURE); 
    }
    else {
       printf("socket ok.\n"); 
    }
    servaddr.sin_family = AF_INET; 
    servaddr.sin_port = htons(UDP_PORT); 
    servaddr.sin_addr.s_addr = inet_addr(UDP_RECEIVER_IP);
}

Transmitter::~Transmitter() {
    close(sockfd);
}

void Transmitter::transmit_frame(Frame *frame, TelemetryStruct *telemetry) {
    frame_number++;
    //Готовим буфер для передачи frame по частям
    unsigned int fr_size = frame->compressed_size;
    //printf ("fr_size: %d\n", fr_size);
    unsigned int frame_chunk_size = UDP_DATAGRAM_SIZE - (UINT_SIZE << 1);
    //ID кадра это timestamp замеренный перед отправкой кадра
    struct timespec monotime;
    clock_gettime(CLOCK_MONOTONIC, &monotime);
    long int time = static_cast<int> (monotime.tv_nsec);
    int frameID = (int)time;
    //printf ("frameID: %d\n", frameID);

    //Количество датаграмм, которые будут посланы для передачи одного кадра
    unsigned int chunks_count = ceil(1.0 * (fr_size + (UINT_SIZE << 1) + TELEMETRY_SIZE) / frame_chunk_size);
    // printf ("chunks_count: %d\n", chunks_count);
    unsigned int datagram_size; //размер датаграммы
    unsigned int payload_size; //количество байт кадра, которые передаются в данной датаграмме
    unsigned int current_position = 0; //количество байт от начала кадра, которые были переданы

    for (unsigned int i = 0; i < chunks_count; i++) {
        if (i == chunks_count - 1) {
            datagram_size = (fr_size + (UINT_SIZE << 1) + TELEMETRY_SIZE) % frame_chunk_size;
            datagram_size += (UINT_SIZE << 1);
        } else {
            datagram_size = UDP_DATAGRAM_SIZE;
        }
        // printf ("datagram_size: %d\n", datagram_size);
        memcpy(datagram, &frameID, UINT_SIZE);
        memcpy(datagram+1, &i, UINT_SIZE);

        if (i == 0) {
            payload_size = datagram_size - (UINT_SIZE << 2) - TELEMETRY_SIZE;
            memcpy(datagram+2, &chunks_count, UINT_SIZE);
            memcpy(datagram+3, &fr_size, UINT_SIZE);
            memcpy(datagram+4, telemetry, TELEMETRY_SIZE);
            memcpy(datagram+6, &(frame->compressed_data[current_position]), payload_size);
        } else {
            payload_size = datagram_size - (UINT_SIZE << 1);
            memcpy(datagram+2, &(frame->compressed_data[current_position]), payload_size);
        }

        current_position += payload_size;
        // printf ("payload_size: %d\n", payload_size);

        sendto(sockfd, datagram, datagram_size,  
            MSG_CONFIRM, (const struct sockaddr *) &servaddr, sizeof(servaddr)); 
        usleep(UDP_PAUSE_AFTER_DTGR_TRANSMIT_uS);
    }
    frame->state = EMPTY;
    printf("FR#%d ID[%d] chunks:%d size:%d\n", frame_number, frameID, chunks_count, fr_size);
}
