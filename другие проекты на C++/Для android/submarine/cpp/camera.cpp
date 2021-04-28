#include "../headers/camera.h"

Camera::Camera()
{
    #if (FRAME_BUFFER_LENGTH <= 0) || (FRAME_BUFFER_LENGTH > 255)
        perror("bad frame buffer length");
    #endif

    #if SIMULATE_CAMERA == false
        rspicamera.setHeight(FRAME_HEIGHT);
        rspicamera.setWidth(FRAME_WIDTH);
        rspicamera.setFrameRate(FRAME_RATE);
        if (!rspicamera.open()) {
            perror("camera error"); 
            exit(EXIT_FAILURE);
        }
        //ждем инициализации камеры
        usleep(3000000);
        frame_size = rspicamera.getImageTypeSize(
                raspicam::RASPICAM_FORMAT_BGR);
    #else
        img_file.open("./res/image.bin", ios::in | ios::binary);
        frame_size = get_frame_size();
    #endif

    //выделяем память под каждый кадр для текущего формата картинки
    for (int i = 0; i < FRAME_BUFFER_LENGTH; i++) {
        FrameBuffer[i].raw_data = new unsigned char[frame_size];
    }
}
Camera::~Camera()
{
    #if SIMULATE_CAMERA == true
        img_file.close();
    #endif
    for (Frame fr : FrameBuffer) {
        delete(fr.raw_data);
        delete(fr.compressed_data);
    }
}

void Camera::capture() {
    if (FrameBuffer[frame_for_capture].state != EMPTY) {
        return;
    }
    Frame* frame = &FrameBuffer[frame_for_capture];
    #if SIMULATE_CAMERA == false
        rspicamera.grab();
        rspicamera.retrieve(
            frame->raw_data,
            raspicam::RASPICAM_FORMAT_IGNORE);
        char r, b;
        for (unsigned int i = 0; i < frame_size / 3; i++) {
            r = frame->raw_data[i*3];
            b = frame->raw_data[i*3+2];
            frame->raw_data[i*3+2] = r;
            frame->raw_data[i*3] = b;
        }
    #else
        read_img_file(frame);
    #endif
    frame->state = CAPTURED;
    frame_for_capture++;
    if (frame_for_capture == FRAME_BUFFER_LENGTH) {
        frame_for_capture = 0;
    }
    // printFrameBuffer();
}

void Camera::compress(char thread) {
    unsigned char frame_for_compress;
    if (thread == 1) {
        frame_for_compress = frame_for_compress1;
    }
    else {
        frame_for_compress = frame_for_compress2;
    }

    if (FrameBuffer[frame_for_compress].state != CAPTURED) {
        return;
    }

    Frame* frame = &FrameBuffer[frame_for_compress];
    jpeg_compress_struct cinfo;
    jpeg_error_mgr jerr;
    cinfo.err = jpeg_std_error(&jerr);
    jerr.trace_level = 10;
    jpeg_create_compress(&cinfo);

    if (frame->compressed_data != NULL) { 
        free(frame->compressed_data);
        frame->compressed_data = NULL;
    }

    long unsigned int size = 0;
    cinfo.image_width = FRAME_WIDTH;
    cinfo.image_height = FRAME_HEIGHT;
    cinfo.input_components = 3;
    cinfo.in_color_space = JCS_RGB;
    jpeg_set_defaults(&cinfo);
    jpeg_set_quality(&cinfo, FRAME_JPG_QUALITY, TRUE);
    jpeg_mem_dest(&cinfo, &(frame->compressed_data), &size); // jpg_data will be set by the library
    jpeg_start_compress(&cinfo, TRUE);

    JSAMPROW row_pointer[1];
    while (cinfo.next_scanline < cinfo.image_height) {
        row_pointer[0] = (JSAMPLE *)(frame->raw_data+cinfo.next_scanline*FRAME_WIDTH*3);
        jpeg_write_scanlines(&cinfo, row_pointer, 1);
    }
    jpeg_finish_compress(&cinfo);
    jpeg_destroy_compress(&cinfo);
    frame->compressed_size = size;
    frame->state = COMPRESSED;
    if (thread == 1) {
        frame_for_compress1++;
        if (frame_for_compress1 == 2) {
            frame_for_compress1 = 0;
        }
    }
    else {
        frame_for_compress2++;
        if (frame_for_compress2 == 4) {
            frame_for_compress2 = 2;
        }
    }
}

Frame* Camera::completed_frame() {
    Frame* frame = &FrameBuffer[frame_for_transmit];
    if (frame->state != COMPRESSED) {
        return NULL;
    }
    else {
        frame_for_transmit++;
        if (frame_for_transmit == FRAME_BUFFER_LENGTH) {
            frame_for_transmit = 0;
        }
        return frame;
    }
}

#if SIMULATE_CAMERA == true
void Camera::read_img_file(Frame *frame) {
    img_file.seekg(0, ios::beg);
    img_file.read((char *)frame->raw_data, frame_size);
}

unsigned int Camera::get_frame_size() {
    if (!img_file) {
        perror("image.bin file open error"); 
        exit(EXIT_FAILURE); 
    }

    img_file.seekg(0, ios::end);
    unsigned int res = (unsigned int)img_file.tellg();
    return res;
}
#endif

void Camera::printFrameBuffer() {
    printf("buffer: ");
    for (Frame fr : FrameBuffer) {
        printf("%d ", fr.state);
    }
    printf("\n");
}