#ifndef PROJECTMANAGER_H
#define PROJECTMANAGER_H
#include <QObject>
#include <QSqlDatabase>
#include <QSqlDriver>
#include <QSqlQuery>
#include <QSqlRelation>
#include <QSqlError>
#include <QSqlRecord>
#include "variantmaptablemodel.h"
#include <QFileInfo>
#include <QFile>
#include <QBuffer>
#include <QPixmap>
#include <QRegExp>
#include "smtp.h"
#include <QRandomGenerator>
#include "settingsfilemanager.h"
#include <QStringList>
#include <QDir>
#include <QSaveFile>
#include <QList>
#include <QSortFilterProxyModel>

//класс менеджера проекта
class ProjectManager : public QObject
{
    Q_OBJECT
public:
    //конструктор класса модели
    //parent - родительский объект, используеться для передачи в родительский класс
    ProjectManager(QObject* parent = nullptr);
    //деструктор класса
    ~ProjectManager();
    //метод, который осуществляет соединение к серверу СУБД
    Q_INVOKABLE void connectToServer();
    //метод, который осуществляет регистрацию нового пользователя в системе
    //lastname - фамилия пользователя для регистрации
    //firstname - имя пользователя для регистрации
    //otch - отчество пользователя для регистрации
    //login - логин пользователя для регистрации
    //email - электронная почта пользователя для регистрации
    //password - пароль пользователя для регистрации
    //emailCodeWrite - код, который был отправлен на предоставленную электронную почту
    Q_INVOKABLE bool registrateNewUser(QString lastname, QString firstname, QString otch, QString login, QString email, QString password, QString emailCodeWrite);
    //метод, который осуществляет проверку предоставленной фотографии требованиям для использования в аватарах
    //path - путь к файлу
    Q_INVOKABLE bool setChangeImagePath(QString path);
    //метод, который отправляет на предоставленную электронную почту код для регистрации
    //lastname - фамилия пользователя для регистрации, нужно для проверки
    //firstname - имя пользователя для регистрации, нужно для проверки
    //otch - отчество пользователя для регистрации, нужно для проверки
    //login - логин пользователя для регистрации, нужен для проверки
    //email - электронная почта, на которую будет отправлен код
    //password - пароль пользователя для регистрации, нужен для проверки
    Q_INVOKABLE bool sendEmailCode(QString lastname, QString firstname, QString otch, QString login, QString email, QString password);
    //метод, который осуществляет авторизацию, посредством данных, сохранённых после прошлой авторизации
    //login - логин или электронная почта, который будет использоваться для авторизации
    //password - пароль, который будет использоваться для авторизации
    Q_INVOKABLE bool authThroughtSettings(QString login, QString password);
    //метод, который осуществляет основную авторизацию
    //logemail - логин или электронная почта
    //password - пароль
    Q_INVOKABLE bool authUser(QString logemail, QString password);
    //метод, который сбрасывает текущий хранящийся в памяти код, отправленный на электронную почту пользователя
    Q_INVOKABLE void resetEmailCode();
    //метод, который отправляет на электронную почту код для сброса пароля
    //email - электронная почта для востановления доступа к аккаунта
    Q_INVOKABLE bool sendResetEmailCode(QString email);
    //метод, который осуществляет смену пароля
    //password - новый пароль, который будет установлен аккаунту
    //emailCodeWrite - код, который был отправлен на электронную почту
    //email - электронная почта, на которую был отправлен код
    Q_INVOKABLE bool resetPassword(QString password, QString emailCodeWrite, QString email);
    //метод, который осуществляет создание беседы
    //name - название беседы
    Q_INVOKABLE bool createConversation(QString name);
    //метод, который возвращает модель данных бесед
    //search - данные для поиска/фильтрации по названию
    Q_INVOKABLE QSortFilterProxyModel* getConversations(QString search = "");
    //метод, который осуществляет адаптацию байтов изображения для QML
    //content - массив байтов изображения
    Q_INVOKABLE QString getImageBytes(QByteArray content);
    //метод, который осуществляет сбром поиска/фильтрации бесед
    Q_INVOKABLE void resetConvFilter();
    //метод, который возвращает пользователей системы
    //search - данные для поиска/фильтрации по данным пользователя
    Q_INVOKABLE VariantMapTableModel* getUsers(QString search = "");
    //метод, который возвращает чёрный список
    //search - данные для поиска/фильтрации по данным пользователя
    Q_INVOKABLE VariantMapTableModel* getBanedUsers(QString search = "");
    //метод, который отгружает данные пользователя
    //id_user - id пользователя, данные которого необходимо загрузить
    Q_INVOKABLE bool getUserData(int id_user = -1);
    //метод, который возвращает лист, в который были загружены данные пользователя
    Q_INVOKABLE QStringList getUserDataList() const;
    //метод, который осуществляет измение личных данных пользователя
    //lastname - новая фамилия пользователя
    //firstname - новое имя пользователя
    //otch - новое отчество пользователя
    Q_INVOKABLE bool setNewFIO(QString lastname, QString firstname, QString otch);
    //метод, который отправляет код на электронную почту, для изменение почты
    //email - электронная почта, на которую будет отправлен код
    Q_INVOKABLE bool sendChangeEmailCode(QString email);
    //метод, который устанавливает новую почту для пользователя
    //email - новая электронная почта
    //code - код, который был отправлен на почту
    Q_INVOKABLE bool setNewEmail(QString email, QString code);
    //метод, который устанавливает новый пароль и логин
    //login - новый логин
    //oldpass - старый пароль для проверки
    //newpass - новый пароль
    //reppass - новый пароль для проверки соответствия
    Q_INVOKABLE bool setNewPassLog(QString login, QString oldpass, QString newpass, QString reppass);
    //метод, который проверяет заблокирован ли пользователь
    //id_user -  id пользователя
    Q_INVOKABLE bool isBlocked(int id_user);
    //метод, который проверяет заблокирован ли пользователем текущий пользователь
    //id_user - id пользователя
    Q_INVOKABLE bool isIBlocked(int id_user);
    //метод, который блокирует пользователя (чёрный список)
    //id - id пользователя
    Q_INVOKABLE bool blockUser(int id);
    //метод, который осуществляет разблокировку пользователя
    //id - id пользователя
    //row - индекс колонки для удаления из модели данных чёрного списка
    Q_INVOKABLE bool restoreUser(int id, int rowid = -1);
    //метод, который создаёт личную беседу с пользователем
    //id - id пользователя
    //name - название беседы
    Q_INVOKABLE bool createPersonalConv(int id, QString name);
    //метод, который устанавливает необходимость обновления списка бесед
    //value - bool значение необходимости
    Q_INVOKABLE void setRefreshConv(bool value);
    //метод, который устанавливает необходимость обновления чёрного списка
    //value - bool значение необходимости
    Q_INVOKABLE void setRefreshBaned(bool value);
    //метод, который возвращает модель стикеров
    Q_INVOKABLE VariantMapTableModel* getStickers();
    //метод, который возвращает модель пользователей для беседы
    //id_conv - id беседы
    Q_INVOKABLE VariantMapTableModel* getUsersForConv(int id_conv);
    //метод, который возвращает id текущего пользователя
    Q_INVOKABLE int getCurrentUserId() const;
    //метод, который проверяет состоит ли пользователь беседу
    //id - id беседы
    Q_INVOKABLE bool hasConv(int id);
    //метод, который загружает данные беседы
    //id - беседы
    Q_INVOKABLE void getChatData(int id);
    //метод, который возвращает переменную, в которую были записаны данные чата
    Q_INVOKABLE QStringList chatData() const;
    //метод, который частично возвращает сообщения для беседы
    //id_chat - id беседы
    Q_INVOKABLE VariantMapTableModel* getMessages(int id_chat);
    //метод, который возвращает следующую часть сообщений для модели данных сообщения, добавляя в неё эти данные
    //id_chat - id беседы
    Q_INVOKABLE bool fetchMessageModel(int id_chat);
    //метод, который проверяет, является ли текущий пользователь создателем беседы
    //id_chat - id беседы
    Q_INVOKABLE bool isCreator(int id);
    //метод, который осуществляет выход пользователя из беседы
    //id_chat - id беседы
    Q_INVOKABLE void exitConv(int id);
    //метод, который осуществляет запись id текущей беседы в переменную
    //id_chat - id беседы
    Q_INVOKABLE void setCurrentConversation(int id);
    //метод, который осуществляет удаление пользователя из беседы
    //id - id связки пользователя и беседы
    Q_INVOKABLE void deleteUserFromConv(int id);
    //метод, который изменяет данные беседы
    //name - название беседы
    //id - id беседы
    Q_INVOKABLE void changeChatData(QString name, int id);
    //метод, который добавляет пользователя в беседу
    //id_user - id пользователя
    //id_conv - id беседы
    Q_INVOKABLE bool addToUserConv(int id_user, int id_conv);
    //метод, который возвращает модель данных для сообщения
    //id_message - id сообщения в беседе
    Q_INVOKABLE VariantMapTableModel* getMessageFiles(int id_message);
    //метод, который возвращает изображения по id в формате воспринимаемом QML
    //id_file - id изображения
    Q_INVOKABLE QString getFullImage(int id_file);
    //метод, который сохраняет файл, по данному пути
    //url - путь, по которому необходимо сохранить файл
    //id_file - id файла
    Q_INVOKABLE bool saveFile(QString url, int id_file);
    //метод, который отправляет сообщение-стикер
    //id - id связки пользователя и беседы
    //content - путь к стикеру
    Q_INVOKABLE bool sendSticker(int id, QString content);
    //метод, который добавляет файл в модель на отправку
    //fileList - пути к файлам
    Q_INVOKABLE void addToFiles(QList<QUrl> filesList);
    //метод, который возвращает модель с файлами на отправку
    Q_INVOKABLE VariantMapTableModel *getFilesSend();
    //метод, который сбрасывает модель с файлами на отправку
    Q_INVOKABLE void resetFileSend();
    //метод, который удаляет файл из модели файлов на отправку
    //id - id файла
    Q_INVOKABLE void deleteFile(int id);
    //метод, который отправляет сообщения в беседу
    //message - содержание сообщения
    //id_conv_user - id связки пользователя и беседы
    Q_INVOKABLE bool sendMessage(QString message, int id_conv_user);
    //метод, который сбрасывает переменную, которая хранит в себе id текущего пользователя
    Q_INVOKABLE void resetCurrentUserId();
private:
    //метод, который записывает в файл настроек данные для автоматической авторизации
    //login - логин или электронная почта на запись
    //password - пароль на запись
    void RememberAuth(QString login, QString password);
    //метод, который хеширует даннуе
    //hashtarget - сторка, которую необходимо захешировать
    QString makeHash(QString hashtarget);
    //метод добавления в модель бесед
    //id - id беседы
    //status - определяет тип опреации (true - добавление, false - удаление)
    void addToConvList(QString id, QString status);
    //метод, который добавляет сообщение в беседу
    //id - id сообщения
    //id - id беседы
    void addToMessageList(int id, int id_chat);
    //метод, который изменяет модель бесед, изменяет последнее сообщение беседы
    //id_chat - id беседы
    void addNewMessageToConvList(int id_chat);

    QSqlDatabase base;
    QSqlQuery* query;

    QSortFilterProxyModel* proxyConv;

    VariantMapTableModel* convModel;
    VariantMapTableModel* banModel;
    VariantMapTableModel* messages;
    VariantMapTableModel* Chat_Users;
    VariantMapTableModel* files;

    bool isRefreshConvNeeded = false;
    bool isRefreshBanedNeeded = false;
    int CurrentConversation = -1;

    QStringList userdata;
    QStringList chatDataList;

    QString convSearchFilter;

    QString emailCode = "";
    QString ChangeimagePath;


    int currentUserId;
signals:
    void workProcessError(QString error);
    void ChangeimagePathChanged();
    void refreshConversations();
};

#endif // PROJECTMANAGER_H
