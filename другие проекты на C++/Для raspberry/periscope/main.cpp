#include "cpp/main_window.h"
#include <QApplication>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    Periscope w;
    w.show();
    return a.exec();
}
