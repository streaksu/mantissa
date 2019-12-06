#ifndef SETTINGS_H
#define SETTINGS_H

#include <QMainWindow>

QString getHomepage();

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
    void on_saveButton_clicked();

private:
    Ui::Settings *ui;
};

#endif // SETTINGS_H
