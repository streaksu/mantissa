#ifndef ABOUT_H
#define ABOUT_H

#include <QMainWindow>
#include <QAbstractButton>

namespace Ui {
class About;
}

class About : public QMainWindow
{
    Q_OBJECT

public:
    explicit About(QWidget *parent = nullptr);
    ~About();

private slots:
    void on_buttonBox_clicked(QAbstractButton *button);

private:
    Ui::About *ui;
};

#endif // ABOUT_H
