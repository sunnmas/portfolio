#include "cpp/main_window.h"

Periscope::Periscope(QWidget *parent):
    QMainWindow(parent)
{

    monitor = new Monitor();
    gamePadSettings = new GamePadSettings();
    widgetStack = new QStackedWidget;
    widgetStack->addWidget(monitor);
    widgetStack->addWidget(gamePadSettings);
    setCentralWidget(widgetStack);


    connect(monitor, SIGNAL(showGamepadSettings()), this, SLOT(showGamepadSettings()));
    connect(gamePadSettings, SIGNAL(closeForm()), this, SLOT(closeGamepadSettings()));
}

Periscope::~Periscope()
{
    delete monitor;
    delete gamePadSettings;
    delete widgetStack;
}

void Periscope::resizeEvent(QResizeEvent *e)
{
    monitor->resize(this->width(), this->height());
}

void Periscope::showGamepadSettings() {
    widgetStack->setCurrentIndex(1);
}

void Periscope::closeGamepadSettings() {
    widgetStack->setCurrentIndex(0);
}

