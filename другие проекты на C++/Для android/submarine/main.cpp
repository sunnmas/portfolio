#include <pthread.h>
#include "defines.h"
#include "headers/camera.h"
#include "headers/transmit.h"
#include "headers/gamepad.h"
#include "headers/telemetry.h"

Gamepad *gamepad = new Gamepad;
Camera *camera = new Camera;

void * receive_gamepad_data(void *arg) {
    while (true) {
        gamepad->receive();
    }
}

void * camera_compress_frame1(void *arg) {
    while (true) {
        camera->compress(1);
    }
}

void * camera_compress_frame2(void *arg) {
    while (true) {
        camera->compress(2);
    }
}

int main (int argc, char **argv) {
    pthread_t gamepad_thread;
    pthread_t compress_thread1, compress_thread2;
    int gamepad_th_id, compress_th_id1, compress_th_id2;

    compress_th_id1 = 1;
    pthread_create(
                &compress_thread1, NULL,
                camera_compress_frame1, &compress_th_id1);
 

    compress_th_id2 = 2;
    pthread_create(
                &compress_thread2, NULL,
                camera_compress_frame2, &compress_th_id2);



    gamepad_th_id = 4;
    pthread_create(
                &gamepad_thread, NULL,
                receive_gamepad_data, &gamepad_th_id);


    Transmitter *transmitter = new Transmitter;
    Telemetry *telemetry = new Telemetry;

    while (true) {
        camera->capture();
        Frame *frame = camera->completed_frame();
        if (frame != NULL) {
            transmitter->transmit_frame(
                frame,
                telemetry->read()
            );            
        }
    }
    delete transmitter;
    delete camera;
    delete telemetry;
    delete gamepad;
    return 0; 
}
