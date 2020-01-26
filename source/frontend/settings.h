#ifndef SETTINGS_H
#define SETTINGS_H

#include <QMainWindow>
#include <QSettings>
#include <QAbstractButton>

QString getHomepage();
bool getAdblock();
int getCookiePolicy();

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
    void on_buttonBox_clicked(QAbstractButton *button);

private:
    QSettings    *settings;
    Ui::Settings *ui;
};

#endif // SETTINGS_H
