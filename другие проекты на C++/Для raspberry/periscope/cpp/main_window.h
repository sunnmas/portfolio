#ifndef PERISCOPE_H
#define PERISCOPE_H
#include <QMainWindow>
#include <QStackedWidget>
#include "cpp/gamepad_settings.h"
#include "cpp/monitor.h"

class Periscope : public QMainWindow
{
    Q_OBJECT

public:
    Periscope(QWidget *parent = nullptr);
    ~Periscope();
protected:
    void resizeEvent(QResizeEvent *event) override;
private:
    QStackedWidget* widgetStack;
    GamePadSettings *gamePadSettings;
    Monitor *monitor;
public slots:
    void showGamepadSettings();
    void closeGamepadSettings();
};
#endif // PERISCOPE_H
