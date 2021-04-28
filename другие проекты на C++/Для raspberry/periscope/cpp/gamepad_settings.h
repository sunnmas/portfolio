#ifndef GAMEPADSETTINGS_H
#define GAMEPADSETTINGS_H

#include <QWidget>
#include <QUdpSocket>
#include "ui_gamepad.h"
#include "cpp/game_pad.h"

#define SUBMARINE_IP "192.168.0.234"
#define SUBMARINE_PORT 22126
namespace Ui {
class GamePadSettingsForm;
}

class GamePadSettings : public QWidget
{
    Q_OBJECT
public:
    explicit GamePadSettings(QWidget *parent = nullptr);
    ~GamePadSettings();
private:
    Ui::GamePadSettingsForm *ui;
    GamePad *gamePad;
    QUdpSocket udpSocket;
    QHostAddress *submarine_ip;
    void sendGamePadState();
signals:
    void closeForm();
public slots:
    void closeFormPressed();
    void gamePadConnected();
    void gamePadDisconnected();
    void gamePadAxisChanged();
    void gamePadButtonChanged(GamePadButton button, bool value);
    void configureWAxis();
    void configureXAxis();
    void configureYAxis();
    void configureZAxis();
    void configureButtonA();
    void configureButtonB();
    void configureButtonSTART();
    void configureButtonL1();
    void configureButtonR1();
    void configureButtonL3();
    void configureButtonUP();
    void configureButtonDOWN();
    void configureButtonLEFT();
    void configureButtonRIGHT();
};

#endif // GAMEPADSETTINGS_H
