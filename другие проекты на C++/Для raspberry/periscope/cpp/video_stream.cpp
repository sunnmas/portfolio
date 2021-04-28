#include "cpp/video_stream.h"

VideoStream::VideoStream(QObject *parent) : QObject(parent)
{
    udpSocket.bind(22125);
    connect(&udpSocket, SIGNAL(readyRead()), this, SLOT(chunkReceived()));
    for (int i = 0; i < FRAME_BUFFER_DEPTH; i++) {
        videoBuffer[i] = *(new VideoFrame);
    }
}

//Вызывается когда пакет кадра приехал
void VideoStream::chunkReceived() {
    QByteArray datagram;
    //qInfo() << "redyread";
    //do {
        datagram.resize(udpSocket.pendingDatagramSize());
        udpSocket.readDatagram(datagram.data(), datagram.size());
    //} while (udpSocket.hasPendingDatagrams());
    //qInfo() << "datagram";
    //return;
    VideoFrame *frame = NULL;
    uint frameID;
    uint chunk_number;
    memcpy(&frameID, datagram.data(), UINT_SIZE);
    memcpy(&chunk_number, datagram.data()+UINT_SIZE, UINT_SIZE);

    if (chunk_number == 0) {
        receivingFrameNumber++;
        if (receivingFrameNumber == FRAME_BUFFER_DEPTH) {
            receivingFrameNumber = 0;
        }
        frame = &videoBuffer[receivingFrameNumber];
        if (frame->state == USELESS) {
            frame->state = CORRUPTED;
        } else if (frame->state == DISPLAYING) {
            return;
        }
        frame->id = frameID;
        memcpy(&(frame->totalChunksCount), datagram.data()+(UINT_SIZE<<1), UINT_SIZE);
        memcpy(&(frame->size), datagram.data()+3*UINT_SIZE, UINT_SIZE);
        memcpy(&(frame->telemetry), datagram.data()+(UINT_SIZE<<2), TELEMETRY_SIZE);
        //qInfo() << "frameSize: " << frameSize;
        frame->picture.resize(frame->size);
        memcpy(frame->picture.data(),
               datagram.data()+(UINT_SIZE<<2)+TELEMETRY_SIZE,
               datagram.size()-(UINT_SIZE<<2)-TELEMETRY_SIZE);
        //qInfo() << "chunksCount: " << frame->totalChunksCount;
        frame->receivedChunksCount = 1;
//        initReceivedChunks(frame);
    } else if (chunk_number > 0) {
        for (int i = 0; i < FRAME_BUFFER_DEPTH; i++) {
            if (videoBuffer[i].id == frameID) {
                frame = &videoBuffer[i]; break;
            }
        }
        if (frame == NULL) return;
        memcpy(frame->picture.data() +
               (UDP_PACKAGE_SIZE-(UINT_SIZE<<2)-TELEMETRY_SIZE) +
                               (chunk_number - 1) * (UDP_PACKAGE_SIZE - (UINT_SIZE<<1)),
               datagram.data()+(UINT_SIZE<<1),
               datagram.size()-(UINT_SIZE<<1));
        frame->receivedChunksCount++;
        //qInfo() << frameID << ":" << frame->receivedChunksCount << ":" << chunk_number;
    }
//    markChunkReceived(frame, chunk_number);

    //if (isFrameReceived()) {

    //Когда потери в кадре начинают соответствовать допустимым значениям, то метим его принятым
    //(хотя данные по кадру могут еще подъезжать в будущем)
    float received_part = 1.0*frame->receivedChunksCount
                           / frame->totalChunksCount;
    if (frame->state == CORRUPTED and
        received_part >= ACCEPTABLE_LOSSES) {
        frame->state = RECEIVED;
        reserveReceivedFrames++;
        //qInfo() << "frame received";
        if (reserveReceivedFrames > FRAMES_RESERVE) {
            emit FrameReceived();

        }
////        QFile file("/home/brainycode/deep.jpeg");
////        file.open(QIODevice::WriteOnly);
////        file.write(frame);
////        file.close();
//        ready_frame.clear();
//        ready_frame.resize(frame.size());
//        memcpy(ready_frame.data(), frame.data(), frame.size());
    }
}

////Инициирует массив receivedChunks, записывая туда информацию о том, что ни один кусок кадра
////еще не был принят, основываясь на количестве ожидаемых кусков в кадре
//void VideoStream::initReceivedChunks(VideoFrame *frame) {
////    uint cnt = frame->totalChunksCount;
////    uint size = ceil(cnt / 8.0);
////    unsigned char free_space = cnt % 8;

////    for (uint i = 0; i < size-1; i++) {
////        frame->receivedChunks.append(free_space & 0x00);
////    }

////    frame->receivedChunks.append(~((1 << free_space)-1));
//}

////Сообщает были ли приняты все куски кадра
//bool VideoStream::calcIsFrameReceived(VideoFrame *frame) {
////    unsigned char result = 0xFF;
////    for (auto x: frame->receivedChunks) {
////        result &= x;
////    }
////    if (result == 0xFF) {
////        return true;
////    } else {
////        return false;
////    }
//}

//// Помечает, что пакет с номером num текущего кадра был принят
//void VideoStream::markChunkReceived(VideoFrame *frame, uint num) {
////    unsigned char local_num = num % 8;
////    int byte_num = num >> 3;
////    char val = frame->received_chunks.at(byte_num) | (1 << local_num);
////    char* target = frame->received_chunks.data()+byte_num;
////    *target = val;
//}

VideoFrame* VideoStream::getNextFrame() {
    VideoFrame *result;
    for (int i = 0; i < FRAME_BUFFER_DEPTH; i++) {
        displayingFrameNumber++;
        if (displayingFrameNumber == FRAME_BUFFER_DEPTH) {
            displayingFrameNumber = 0;
        }
        result = &videoBuffer[displayingFrameNumber];
        if (result->state == RECEIVED) {
            result->state = DISPLAYING;
            return result;
        }
    }
    return result;
}

void VideoStream::frameDisplayed(VideoFrame *frame) {
    reserveReceivedFrames--;
    frame->state = USELESS;
}
