#ifndef SMTP_H
#define SMTP_H


#include <QtNetwork/QAbstractSocket>
#include <QtNetwork/QSslSocket>
#include <QString>
#include <QTextStream>
#include <QDebug>
#include <QByteArray>


//класс реализующий функционал SMTP-сервера
class Smtp : public QObject
{
    Q_OBJECT
public:
    //конструктор класса
    //user - адресс электронной почты для smtp
    //pass - пароль от электронной почты
    //host - адресс smtp-сервера, который будет использоваться при отправке
    //port - порт, по которому будет осуществляться подключение
    //timeout - таймаут на подключение к серверу
    Smtp( const QString &user, const QString &pass, const QString &host, int port = 465, int timeout = 30000);
    //деструктор класса
    ~Smtp();
    //метод, который отправляет сообщение на электронную почту
    //from - имя/адресс от кого отправленно (не обязательно фактический)
    //to - адресс электронной почты, на которую будет отправлено сообщение
    //subject - тема сообщения
    //body - тело сообщения (его текст)
    void sendMail( const QString &from, const QString &to, const QString &subject, const QString &body );
signals:
    //сигнал, который сообщяет, о проишествиях в классе
    //принимает в себя текст сигнала
    void status( const QString &);
private slots:
    //метод-слот, который происходит при изменении статуса соединения
    //socketState - енумарация, описывающая состояние
    void stateChanged(QAbstractSocket::SocketState socketState);
    //метод-слот, который происходит при получении ошибки сокетом
    //socketState - енумарация, описывающая тип ошибки
    void errorReceived(QAbstractSocket::SocketError socketError);
    //метод-слот, который происходит при отключении сокета
    void disconnected();
    //метод-слот, который происходит при отключении сокета
    void connected();
    //метод-слот, который происходит при получении данных в сокет от сервера
    void readyRead();
private:
    int timeout;
    QString message;
    QTextStream *t;
    QSslSocket *socket;
    QString from;
    QString rcpt;
    QString response;
    QString user;
    QString pass;
    QString host;
    int port;
    enum states{Tls, HandShake ,Auth,User,Pass,Rcpt,Mail,Data,Init,Body,Quit,Close};
    int state;
};
#endif
