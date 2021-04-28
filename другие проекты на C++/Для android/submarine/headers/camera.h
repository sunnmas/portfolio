#ifndef CAMERA_H
#define CAMERA_H
#include "../defines.h"

#if SIMULATE_CAMERA == false
    #include <raspicam/raspicam.h>
#endif
#include <unistd.h>
#include <fstream>
#include <iostream>
#include "../defines.h"

extern "C"
{
    #include <jpeglib.h>
}

using namespace std;

enum FrameState {
    EMPTY,
    CAPTURED,
    COMPRESSED
};

struct Frame {
    unsigned char* raw_data = NULL;
    unsigned char* compressed_data = NULL;
    unsigned long compressed_size = 0;
    FrameState state = EMPTY;
};

class Camera
{
public:
    explicit Camera();
    virtual ~Camera();
    void capture();
    void compress(char thread);
    Frame* completed_frame();
private:
    #if SIMULATE_CAMERA == false
        raspicam::RaspiCam rspicamera;
    #else
        ifstream img_file;
        unsigned int get_frame_size();
        void read_img_file(Frame *frame);
    #endif
    Frame FrameBuffer[FRAME_BUFFER_LENGTH];
    unsigned char frame_for_capture = 0;
    unsigned char frame_for_compress1 = 0;
    unsigned char frame_for_compress2 = 2;
    unsigned char frame_for_transmit = 0;
    unsigned int frame_size;

    void printFrameBuffer();
};
#endif //CAMERA_H