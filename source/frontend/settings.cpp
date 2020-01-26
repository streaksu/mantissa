#include "frontend/settings.h"

#include "ui_settings.h"
#include "globals.h"
#include "frontend/about.h"
#include <QSettings>
#include <QUrl>

#define HOMEPAGE_KEY     "homepage"
#define ADBLOCK_KEY     "adblock"
#define COOKIEPOLICY_KEY "cookiepolicy"

QString getHomepage()
{
     auto settings = new QSettings(PROJECTNAME);
     auto homepage = settings->value(HOMEPAGE_KEY).toString();
     delete settings;
     return homepage;
}

bool getAdblock()
{
    auto settings = new QSettings(PROJECTNAME);
    auto addblocker = settings->value(ADBLOCK_KEY).toBool();
    delete settings;
    return addblocker;
}

int getCookiePolicy()
{
    auto settings = new QSettings(PROJECTNAME);
    auto policy = settings->value(COOKIEPOLICY_KEY).toInt();
    delete settings;
    return policy;
}

Settings::Settings(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::Settings)
{
    settings = new QSettings(PROJECTNAME);
    ui->setupUi(this);
    setAttribute(Qt::WA_DeleteOnClose);
    setWindowTitle(QString(PROJECTNAME) + " - Settings");

    ui->homepageBar->setText(getHomepage());
    ui->adblockCheck->setCheckState(getAdblock() ? Qt::CheckState::Checked : Qt::CheckState::Unchecked);
    ui->cookiePolicyBox->addItems(
        (QStringList() << "Never save cookies" << "Save persistent cookies" << "Force persistent cookies")
    );
    ui->cookiePolicyBox->setCurrentIndex(getCookiePolicy());
}

Settings::~Settings()
{
    delete settings;
    delete ui;
}

void Settings::on_aboutButton_clicked()
{
    auto about = new About();
    about->show();
}

void Settings::on_buttonBox_clicked(QAbstractButton *button)
{
    if (button == ui->buttonBox->button(QDialogButtonBox::Save)) {
        settings->setValue(HOMEPAGE_KEY,     QUrl::fromUserInput(ui->homepageBar->text()).toString());
        settings->setValue(ADBLOCK_KEY,      ui->adblockCheck->checkState() == Qt::CheckState::Checked);
        settings->setValue(COOKIEPOLICY_KEY, ui->cookiePolicyBox->currentIndex());
    }

    close();
}
