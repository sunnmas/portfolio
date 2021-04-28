#include "monitor.h"
//#include "QFile"
Monitor::Monitor(QWidget *parent) : QWidget(parent),
  ui(new Ui::Monitor)
{
    fpsTimer.setInterval(1000);
    connect(&fpsTimer, SIGNAL(timeout()), this, SLOT(updateFPS()));
    fpsTimer.start(1000);

    connect(&nosignalTimer, SIGNAL(timeout()), this, SLOT(noSignal()));

    QPalette p;
    p.setColor(QPalette::Background, QColor(0,0,0,0));

    ui->setupUi(this);
    QImage image(":res/scope.png");
    ui->scope->setPixmap(QPixmap::fromImage(image));
    ui->scope->setScaledContents(true);
    ui->scope->resize(this->width(), this->height());
    ui->scope->setPalette(p);

    QImage image2(":res/nosignal.jpg");
    ui->water->setPixmap(QPixmap::fromImage(image2));
    ui->water->setScaledContents(true);
    ui->water->resize(this->width(), this->height());

    ui->frameSize->setPalette(p);
    ui->packages->setPalette(p);
    ui->fps->setPalette(p);
    ui->depth->setPalette(p);
    ui->power->setPalette(p);

    connect(&stream, SIGNAL(FrameReceived()), this, SLOT(FrameReceived()));
    connect(ui->showGamepadSettings, SIGNAL(pressed()), this, SLOT(showGamepadSettingsPressed()));
}

Monitor::~Monitor() {
    delete ui;
}

void Monitor::updateFPS() {
    ui->fps->setText("fps: "+QString::number(fps));
    fps = 0;
}

void Monitor::FrameReceived() {
    nosignalTimer.stop();
    nosignalTimer.start(2000);
    VideoFrame *frame;
    frame = stream.getNextFrame();

//    QFile file("test1.jpg");
//    file.open(QIODevice::WriteOnly);
//    file.write(frame->picture);
//    file.close();

    frameImage.loadFromData(frame->picture, "JPEG");
    ui->water->setPixmap(QPixmap::fromImage(frameImage));
    stream.frameDisplayed(frame);
    fps++;

    ui->frameSize->setText("Размер кадра: "+QString::number(frame->size));
    ui->packages->setText("Принято: "+QString::number(frame->receivedChunksCount) +"/"+QString::number(frame->totalChunksCount));
    ui->power->setText("Батарея: "+QString::number(frame->telemetry.power) +"%");
    ui->depth->setText("Глубина: "+QString::number(frame->telemetry.depth) +"м");
}

void Monitor::showGamepadSettingsPressed() {
    emit showGamepadSettings();
}

void Monitor::noSignal() {
    QImage image(":res/nosignal.jpg");
    ui->water->setPixmap(QPixmap::fromImage(image));
}

void Monitor::resizeEvent(QResizeEvent *e)
{
    ui->water->resize(this->width(), this->height());
    ui->scope->resize(this->width(), this->height());
}
