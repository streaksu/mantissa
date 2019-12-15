#ifndef SETTINGS_H
#define SETTINGS_H

#include <QMainWindow>
#include <QSettings>

QString getHomepage();
bool getAddblock();

namespace Ui {
class Settings;
}

class Settings : public QMainWindow
{
    Q_OBJECT

public:
    explicit Settings(QWidget *parent = nullptr);
    ~Settings();

private slots:
    void on_aboutButton_clicked();
    void on_closeButton_clicked();
    void on_saveButton_clicked();

private:
    QSettings    *settings;
    Ui::Settings *ui;
};

#endif // SETTINGS_H
