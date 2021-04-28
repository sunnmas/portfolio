#include "game_pad.h"

GamePad::GamePad(QObject *parent) : QObject(parent)
{
    padManager = QGamepadManager::instance();
    connect(&connectionTimer, SIGNAL(timeout()), this, SLOT(updateConnection()));
    connectionTimer.start(JOYSTICK_PING_PERIOD_MS);

    connect(&checkAxisesTimer, SIGNAL(timeout()), this, SLOT(updateAxises()));
    checkAxisesTimer.start(JOYSTICK_CHECK_AXISES_PERIOD_MS);
}

void GamePad::updateConnection() {
    auto gamepads = padManager->connectedGamepads();
    if (gamepads.size() == 0) {
        if (attached) {
            deviseID = -1;
            attached = false;
            emit disconnected();
            qInfo() << "gamepad disconnected";
        }
        return;
    } else {
        attached = true;
        pad = new QGamepad(gamepads.first());
        if (deviseID != pad->deviceId()) deviseID = pad->deviceId();
        else return;
        emit connected();
        qInfo() << "gamepad connected";
        qInfo() << "gamepad id: " << deviseID;
    }
    connect(pad, SIGNAL(axisRightXChanged(double)), this, SLOT(axisWChanged(double)));
    connect(pad, SIGNAL(axisLeftXChanged(double)), this, SLOT(axisXChanged(double)));
    connect(pad, SIGNAL(axisLeftYChanged(double)), this, SLOT(axisYChanged(double)));
    connect(pad, SIGNAL(axisRightYChanged(double)), this, SLOT(axisZChanged(double)));

    connect(pad, SIGNAL(buttonAChanged(bool)), this, SLOT(buttonAChanged(bool)));
    connect(pad, SIGNAL(buttonBChanged(bool)), this, SLOT(buttonBChanged(bool)));
    connect(pad, SIGNAL(buttonStartChanged(bool)), this, SLOT(buttonSTARTChanged(bool)));
    connect(pad, SIGNAL(buttonL1Changed(bool)), this, SLOT(buttonL1Changed(bool)));
    connect(pad, SIGNAL(buttonR1Changed(bool)), this, SLOT(buttonR1Changed(bool)));
    connect(pad, SIGNAL(buttonL3Changed(bool)), this, SLOT(buttonL3Changed(bool)));
    connect(pad, SIGNAL(buttonUpChanged(bool)), this, SLOT(buttonUPChanged(bool)));
    connect(pad, SIGNAL(buttonDownChanged(bool)), this, SLOT(buttonDOWNChanged(bool)));
    connect(pad, SIGNAL(buttonLeftChanged(bool)), this, SLOT(buttonLEFTChanged(bool)));
    connect(pad, SIGNAL(buttonRightChanged(bool)), this, SLOT(buttonRIGHTChanged(bool)));
}

void GamePad::updateAxises() {
    if (attached) {
        emit axisChanged();
    }
}

GamePadState GamePad::getState() {
    return state;
}

void GamePad::axisWChanged(double value) {
    state.W = value;
}

void GamePad::axisXChanged(double value) {
    state.X = value;
}

void GamePad::axisYChanged(double value) {
    state.Y = value;
}

void GamePad::axisZChanged(double value) {
    state.Z = value;
}

void GamePad::buttonAChanged(bool value) {
    state.A = value;
    emit buttonChanged(A, value);
}

void GamePad::buttonBChanged(bool value) {
    state.B = value;
    emit buttonChanged(B, value);
}

void GamePad::buttonSTARTChanged(bool value) {
    state.START = value;
    emit buttonChanged(START, value);
}

void GamePad::buttonL1Changed(bool value) {
    state.L1 = value;
    emit buttonChanged(L1, value);
}

void GamePad::buttonR1Changed(bool value) {
    state.R1 = value;
    emit buttonChanged(R1, value);
}

void GamePad::buttonL3Changed(bool value) {
    state.L3 = value;
    emit buttonChanged(L3, value);
}

void GamePad::buttonUPChanged(bool value) {
    state.UP = value;
    emit buttonChanged(UP, value);
}

void GamePad::buttonDOWNChanged(bool value) {
    state.DOWN = value;
    emit buttonChanged(DOWN, value);
}

void GamePad::buttonLEFTChanged(bool value) {
    state.LEFT = value;
    emit buttonChanged(LEFT, value);
}

void GamePad::buttonRIGHTChanged(bool value) {
    state.RIGHT = value;
    emit buttonChanged(RIGHT, value);
}

void GamePad::configureWAxis() {
    qInfo() << "config W axis";
    padManager->configureAxis(deviseID, QGamepadManager::AxisRightX);
}

void GamePad::configureXAxis() {
    qInfo() << "config X axis";
    padManager->configureAxis(deviseID, QGamepadManager::AxisLeftX);
}

void GamePad::configureYAxis() {
    qInfo() << "config Y axis";
    padManager->configureAxis(deviseID, QGamepadManager::AxisLeftY);
}

void GamePad::configureZAxis() {
    qInfo() << "config Z axis";
    padManager->configureAxis(deviseID, QGamepadManager::AxisRightY);
}

void GamePad::configureButtonA() {
    qInfo() << "config button A";
    padManager->configureButton(deviseID, QGamepadManager::ButtonA);
}

void GamePad::configureButtonB() {
    qInfo() << "config button B";
    padManager->configureButton(deviseID, QGamepadManager::ButtonB);
}

void GamePad::configureButtonSTART() {
    qInfo() << "config button START";
    padManager->configureButton(deviseID, QGamepadManager::ButtonStart);
}

void GamePad::configureButtonL1() {
    qInfo() << "config button L1";
    padManager->configureButton(deviseID, QGamepadManager::ButtonL1);
}

void GamePad::configureButtonR1() {
    qInfo() << "config button R1";
    padManager->configureButton(deviseID, QGamepadManager::ButtonR1);
}

void GamePad::configureButtonL3() {
    qInfo() << "config button L3";
    padManager->configureButton(deviseID, QGamepadManager::ButtonL3);
}

void GamePad::configureButtonUP() {
    qInfo() << "config button UP";
    padManager->configureButton(deviseID, QGamepadManager::ButtonUp);
}

void GamePad::configureButtonDOWN() {
    qInfo() << "config button DOWN";
    padManager->configureButton(deviseID, QGamepadManager::ButtonDown);
}

void GamePad::configureButtonLEFT() {
    qInfo() << "config button LEFT";
    padManager->configureButton(deviseID, QGamepadManager::ButtonLeft);
}

void GamePad::configureButtonRIGHT() {
    qInfo() << "config button RIGHT";
    padManager->configureButton(deviseID, QGamepadManager::ButtonRight);
}

