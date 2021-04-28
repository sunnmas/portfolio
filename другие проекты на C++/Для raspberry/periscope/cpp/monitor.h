#ifndef MONITOR_H
#define MONITOR_H

#include <QWidget>
#include <QTimer>
#include "ui_monitor.h"
#include "cpp/video_stream.h"

namespace Ui {
    class Monitor;
}

class Monitor : public QWidget
{
    Q_OBJECT
public:
    explicit Monitor(QWidget *parent = nullptr);
    ~Monitor();
private:
    Ui::Monitor *ui;
    QImage frameImage;
    VideoStream stream;
    QTimer fpsTimer;
    QTimer nosignalTimer;
    uint fps = 0;
protected:
    void resizeEvent(QResizeEvent *event) override;
signals:
    void showGamepadSettings();
public slots:
    void FrameReceived();
    void updateFPS();
    void showGamepadSettingsPressed();
    void noSignal();
};

#endif // MONITOR_H
