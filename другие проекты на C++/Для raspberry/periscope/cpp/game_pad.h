#ifndef GAME_PAD_H
#define GAME_PAD_H
#include <QObject>
#include <QGamepad>
#include <QGamepadManager>
#include <QTimer>
#include <QDebug>
#define JOYSTICK_PING_PERIOD_MS 655 //Период опроса джойстика на дисконнект в мсек.
#define JOYSTICK_CHECK_AXISES_PERIOD_MS 200 //Период опроса осей джойстика в мсек.
enum GamePadAxis {
    W = 0, X, Y, Z
};

enum GamePadButton {
    A = 0, B, START,
    L1, R1, L3,
    UP, DOWN, LEFT, RIGHT
};

struct GamePadState {
    double W = 0.0;
    double X = 0.0;
    double Y = 0.0;
    double Z = 0.0;
    bool A = false;
    bool B = false;
    bool START = false;
    bool L1 = false;
    bool R1 = false;
    bool L3 = false;
    bool UP = false;
    bool DOWN = false;
    bool LEFT = false;
    bool RIGHT = false;
};

class GamePad : public QObject
{
    Q_OBJECT

public:
    explicit GamePad(QObject *parent = nullptr);
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
    GamePadState getState();
private:
    bool attached = false;
    int deviseID = -1;
    QGamepadManager *padManager;
    QGamepad *pad;
    QTimer connectionTimer;
    QTimer checkAxisesTimer;
    GamePadState state;
signals:
    void connected();
    void disconnected();
    void axisChanged();
    void buttonChanged(GamePadButton button, bool value);
public slots:
    void axisWChanged(double value);
    void axisXChanged(double value);
    void axisYChanged(double value);
    void axisZChanged(double value);
    void buttonAChanged(bool value);
    void buttonBChanged(bool value);
    void buttonSTARTChanged(bool value);
    void buttonL1Changed(bool value);
    void buttonR1Changed(bool value);
    void buttonL3Changed(bool value);
    void buttonUPChanged(bool value);
    void buttonDOWNChanged(bool value);
    void buttonLEFTChanged(bool value);
    void buttonRIGHTChanged(bool value);
    void updateConnection();
    void updateAxises();
};

#endif // GAME_PAD_H
