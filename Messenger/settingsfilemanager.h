#ifndef SETTINGSFILEMANAGER_H
#define SETTINGSFILEMANAGER_H

#include <QObject>
#include <QSettings>
#include <QCoreApplication>

//класс для взаимодействия с файлом настроек
class SettingsFileManager : public QObject
{
    Q_OBJECT
public:
    //контруктор класса
    //parent - родительский элемент, передаётся в в родительский класс
    SettingsFileManager(QObject *parent = nullptr);
    //метод, который записывает данные в файл настроек
    //title - заголовок настройки, по которому будет записано значение
    //setting - настройка, которая будет записана
    Q_INVOKABLE void write(QString title, QString setting);
    //метод, который осуществляет чтение данных из файла настроек
    //title - заголовок настройки, к которому будет осуществляться запрос
    Q_INVOKABLE QString read(QString title);
};

#endif // SETTINGSFILEMANAGER_H
