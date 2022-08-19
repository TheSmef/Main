#include "settingsfilemanager.h"

SettingsFileManager::SettingsFileManager(QObject *parent)
    : QObject{parent}
{

}

void SettingsFileManager::write(QString title, QString setting)
{
    QSettings setFile(QCoreApplication::applicationDirPath() + "/settings.ini", QSettings::IniFormat);
    if (setting.contains(".")){
        int lastIndex = setting.lastIndexOf("/");
        setting = setting.left(lastIndex);
    }
    setFile.setValue(title, setting);

}

QString SettingsFileManager::read(QString titleName)
{
    QSettings setFile(QCoreApplication::applicationDirPath() + "/settings.ini", QSettings::IniFormat);

     QString strFile = setFile.value(titleName).toString();


     return strFile;
}
