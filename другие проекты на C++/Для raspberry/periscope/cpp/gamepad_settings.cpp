#include "gamepad_settings.h"

GamePadSettings::GamePadSettings(QWidget *parent) : QWidget(parent),
    ui(new Ui::GamePadSettingsForm)
{
    ui->setupUi(this);
    submarine_ip = new QHostAddress(SUBMARINE_IP);
    gamePad = new GamePad();
    connect(gamePad, SIGNAL(connected()), this, SLOT(gamePadConnected()));
    connect(gamePad, SIGNAL(disconnected()), this, SLOT(gamePadDisconnected()));
    connect(gamePad, SIGNAL(axisChanged()), this, SLOT(gamePadAxisChanged()));
    connect(gamePad, SIGNAL(buttonChanged(GamePadButton, bool)), this, SLOT(gamePadButtonChanged(GamePadButton, bool)));
    connect(ui->configureW, SIGNAL(pressed()), this, SLOT(configureWAxis()));
    connect(ui->configureX, SIGNAL(pressed()), this, SLOT(configureXAxis()));
    connect(ui->configureY, SIGNAL(pressed()), this, SLOT(configureYAxis()));
    connect(ui->configureZ, SIGNAL(pressed()), this, SLOT(configureZAxis()));
    connect(ui->configureA, SIGNAL(pressed()), this, SLOT(configureButtonA()));
    connect(ui->configureB, SIGNAL(pressed()), this, SLOT(configureButtonB()));
    connect(ui->configureSTART, SIGNAL(pressed()), this, SLOT(configureButtonSTART()));
    connect(ui->configureL1, SIGNAL(pressed()), this, SLOT(configureButtonL1()));
    connect(ui->configureR1, SIGNAL(pressed()), this, SLOT(configureButtonR1()));
    connect(ui->configureL3, SIGNAL(pressed()), this, SLOT(configureButtonL3()));
    connect(ui->configureUP, SIGNAL(pressed()), this, SLOT(configureButtonUP()));
    connect(ui->configureDOWN, SIGNAL(pressed()), this, SLOT(configureButtonDOWN()));
    connect(ui->configureLEFT, SIGNAL(pressed()), this, SLOT(configureButtonLEFT()));
    connect(ui->configureRIGHT, SIGNAL(pressed()), this, SLOT(configureButtonRIGHT()));
    connect(ui->CLOSE, SIGNAL(pressed()), this, SLOT(closeFormPressed()));
}

GamePadSettings::~GamePadSettings() {
    delete ui;
    delete submarine_ip;
    delete gamePad;
}

void GamePadSettings::sendGamePadState() {
    GamePadState state = gamePad->getState();
    QByteArray datagram;
    datagram.resize(sizeof(state));
    memcpy(datagram.data(), &state, sizeof(state));
    udpSocket.writeDatagram(datagram, *submarine_ip, SUBMARINE_PORT);
}

void GamePadSettings::gamePadConnected() {
    ui->state->setText("Джойстик подключен");
    ui->configureA->setEnabled(true);
    ui->configureB->setEnabled(true);
    ui->configureSTART->setEnabled(true);
    ui->configureL1->setEnabled(true);
    ui->configureR1->setEnabled(true);
    ui->configureL3->setEnabled(true);
    ui->configureUP->setEnabled(true);
    ui->configureDOWN->setEnabled(true);
    ui->configureLEFT->setEnabled(true);
    ui->configureRIGHT->setEnabled(true);

    ui->configureW->setEnabled(true);
    ui->configureX->setEnabled(true);
    ui->configureY->setEnabled(true);
    ui->configureZ->setEnabled(true);
}

void GamePadSettings::gamePadDisconnected() {
    ui->state->setText("Джойстик отключен");
    ui->configureA->setEnabled(false);
    ui->configureB->setEnabled(false);
    ui->configureSTART->setEnabled(false);
    ui->configureL1->setEnabled(false);
    ui->configureR1->setEnabled(false);
    ui->configureL3->setEnabled(false);
    ui->configureUP->setEnabled(false);
    ui->configureDOWN->setEnabled(false);
    ui->configureLEFT->setEnabled(false);
    ui->configureRIGHT->setEnabled(false);

    ui->configureW->setEnabled(false);
    ui->configureX->setEnabled(false);
    ui->configureY->setEnabled(false);
    ui->configureZ->setEnabled(false);
}

void GamePadSettings::gamePadAxisChanged() {
    GamePadState state = gamePad->getState();
    ui->Wdial->setValue(state.W*100);
    ui->Xdial->setValue(state.X*100);
    ui->Ydial->setValue(state.Y*100);
    ui->Zdial->setValue(state.Z*100);
    sendGamePadState();
}

void GamePadSettings::gamePadButtonChanged(GamePadButton button, bool value) {
    switch (button) {
        case A: ui->A->setChecked(value); break;
        case B: ui->B->setChecked(value); break;
        case START: ui->START->setChecked(value); break;
        case L1: ui->L1->setChecked(value); break;
        case R1: ui->R1->setChecked(value); break;
        case L3: ui->L3->setChecked(value); break;
        case UP: ui->UP->setChecked(value); break;
        case DOWN: ui->DOWN->setChecked(value); break;
        case LEFT: ui->LEFT->setChecked(value); break;
        case RIGHT: ui->RIGHT->setChecked(value); break;
    }
    sendGamePadState();
}

void GamePadSettings::configureWAxis() {
    gamePad->configureWAxis();
}

void GamePadSettings::configureXAxis() {
    gamePad->configureXAxis();
}

void GamePadSettings::configureYAxis() {
    gamePad->configureYAxis();
}

void GamePadSettings::configureZAxis() {
    gamePad->configureZAxis();
}

void GamePadSettings::configureButtonA() {
    gamePad->configureButtonA();
}

void GamePadSettings::configureButtonB() {
    gamePad->configureButtonB();
}

void GamePadSettings::configureButtonSTART() {
    gamePad->configureButtonSTART();
}

void GamePadSettings::configureButtonL1() {
    gamePad->configureButtonL1();
}

void GamePadSettings::configureButtonR1() {
    gamePad->configureButtonR1();
}

void GamePadSettings::configureButtonL3() {
    gamePad->configureButtonL3();
}

void GamePadSettings::configureButtonUP() {
    gamePad->configureButtonUP();
}

void GamePadSettings::configureButtonDOWN() {
    gamePad->configureButtonDOWN();
}

void GamePadSettings::configureButtonLEFT() {
    gamePad->configureButtonLEFT();
}

void GamePadSettings::configureButtonRIGHT() {
    gamePad->configureButtonRIGHT();
}

void GamePadSettings::closeFormPressed() {
    emit closeForm();
}
