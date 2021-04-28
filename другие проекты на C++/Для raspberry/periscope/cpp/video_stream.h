#ifndef UDPRECEIVER_H
#define UDPRECEIVER_H
#include <QObject>
#include <vector>
#include <QUdpSocket>
#include <QDataStream>
#include <QtMath>
#include <QDebug>

//#define WIFI_LAN false
//Размер пакета в байтах:
#define UDP_PACKAGE_SIZE 1132
//Размер буфера видео сигнала в кадрах:
#define FRAME_BUFFER_DEPTH 10
//Допустимые потери в кадре, когда кадр считается
//принятым. от 0 до 1 (типа 0.9 это 10% потерь):
#define ACCEPTABLE_LOSSES 0.9
//Количество принятых кадров, после которых начнется
//их отображение (хочется запас готовых к отображению кадров):
#define FRAMES_RESERVE 2
//#if WIFI_LAN == true

//#else
//    #define UDP_PACKAGE_SIZE 1432
//    #define FRAME_BUFFER_DEPTH 50
//    #define ACCEPTABLE_LOSSES 0.95
//    #define FRAMES_RESERVE 3
//#endif
#define UINT_SIZE sizeof(uint)
#define TELEMETRY_SIZE sizeof(Telemetry)

enum FrameState {
    CORRUPTED = 0, RECEIVED, DISPLAYING, USELESS
};

struct Telemetry {
    unsigned char power;
    float depth;
};

struct VideoFrame {
    uint id; //уникальное для каждого кадра число
    uint size; //размер кадра в байтах
    QByteArray picture; //сжатая в формате JPEG картинка
    uint receivedChunksCount = 0;
    uint totalChunksCount; //количество ожидаемых пакетов в кадре
    Telemetry telemetry;
    FrameState state = CORRUPTED;
};

class VideoStream : public QObject
{
    Q_OBJECT
public:
    explicit VideoStream(QObject *parent = nullptr);
    VideoFrame* getNextFrame(); //возвращает кадр, который нужно отрисовать
    void frameDisplayed(VideoFrame *frame);
private:
    QUdpSocket udpSocket;
    int receivingFrameNumber = -1;
    int displayingFrameNumber = -1;
    int reserveReceivedFrames = 0; //Количество готовых к отображению кадров
    VideoFrame videoBuffer[FRAME_BUFFER_DEPTH];
public slots:
    void chunkReceived();
signals:
    void FrameReceived();
};

#endif // UDPRECEIVER_H
