#include "projectmanager.h"


ProjectManager::ProjectManager(QObject* parent):QObject(parent)
{

}

ProjectManager::~ProjectManager()
{

}

void ProjectManager::connectToServer()
{
    resetFileSend();
    convModel = new VariantMapTableModel();
    base = QSqlDatabase::addDatabase("QPSQL");
    base.setHostName("127.0.0.1");
    base.setPort(5432);
    base.setDatabaseName("Messenger");
    base.setUserName("postgres");
    base.setPassword("123");
    base.open();
    if (!base.isOpen())
    {
        emit workProcessError("Отсутствует подключение к серверу, попробуйте позже");
        qDebug() << base.lastError();
    }
    query = new QSqlQuery(base);
    if (!base.driver()->subscribeToNotification("insert_chat_users_notf")){
        qDebug() << base.lastError();
    }
    if (!base.driver()->subscribeToNotification("insert_message_notf")){
        qDebug() << base.lastError();
    }
    connect(base.driver(), static_cast<void(QSqlDriver::*)(const QString &, QSqlDriver::NotificationSource, const QVariant &)>(&QSqlDriver::notification), this,
                     [=](const QString &name, QSqlDriver::NotificationSource source, const QVariant &payload)
                     {
                         Q_UNUSED(source);
                         qDebug() << "notify:" << name << ", payload:" << payload.toString();
                         if (name == "insert_chat_users_notf"){
                             QStringList mass = payload.toString().split(' ');
                             if (mass[1].toInt() == currentUserId){
                                 emit refreshConversations();
                                 if(isRefreshConvNeeded)
                                     addToConvList(mass[0], mass[2]);
                                 emit workProcessError("Список бесед был обновлён");
                             }
                         }
                         else if(name == "insert_message_notf"){
                             QStringList mass = payload.toString().split(' ');
                             if (hasConv(mass[1].toInt())){
                                 if(isRefreshConvNeeded)
                                    addNewMessageToConvList(mass[1].toInt());
                             if (mass[1].toInt() == CurrentConversation){
                                 addToMessageList(mass[0].toInt(), mass[1].toInt());
                             }
                             }
                         }
                     });
}


bool ProjectManager::registrateNewUser(QString lastname, QString firstname, QString otch, QString login, QString email, QString password, QString emailCodeWrite)
{
    QString emailRegEx = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,6}$";
    QString passwordRegEx = "^(?=.*[0-9])(?=.*[!@#$%^&*])(?=.*[a-z])(?=.*[A-Z])[0-9a-zA-Z!@#$%^&*]{8,30}$";
    QRegExp* exp = new QRegExp(emailRegEx);
    int idFILE;
    query->prepare("select id_user from users where login = :LOGIN_ACT");
    query->bindValue(":LOGIN_ACT", login);
    if (!query->exec()){
        emit workProcessError("Непредвиденная ошибка связанная \n с подключением");
        return false;
    }
    if (query->next()){
        emit workProcessError("Данный логин занят другим пользователем");
        return false;
    }
    if (emailCodeWrite != emailCode && emailCode != ""){
        emit workProcessError("Код подтверждения почты - неправильный");
        return false;
    }
    if (lastname == "" || firstname == "" || login == "" || email == "" || password == ""){
        emit workProcessError("Не были введены необходимые данные\n Для ввода обязательны все данные, кроме Отчества");
        return false;
    }
    if (!exp->exactMatch(email)){
        emit workProcessError("Введённый email - некорректный");
        return false;
    }
    exp = new QRegExp(passwordRegEx);
    if (!exp->exactMatch(password)){
        emit workProcessError("Введённый пароль - некорректный\n Требования к паролю:\n Как минимум 1 заглавная буква,\n1 прописная буква,\n1 цифра и 1 спец. символ (!@#$%^&*)\n Размер от 8 до 30 символов");
        return false;
    }
    if (ChangeimagePath != nullptr && ChangeimagePath != ""){
        QFileInfo* file = new QFileInfo(ChangeimagePath);
        query->prepare("INSERT INTO files (file_name, file_content, file_content_imagescaled, file_extension) VALUES (:NAME_CONTENT, :CONTENT_CONTENT, :SCALED_CONTENT, :EXTENSION_CONTENT) RETURNING id_file as id");
        query->bindValue(":NAME_CONTENT", file->completeBaseName());
        QFile FileAct(file->absoluteFilePath());
        if (!FileAct.exists()){
            emit workProcessError("Непредвиденная ошибка связанная с файлом аватара профиля");
            return false;
        }
        QByteArray inByteArray;
        QBuffer inBuffer( &inByteArray );
        inBuffer.open( QIODevice::WriteOnly);
        FileAct.open(QIODevice::ReadOnly);
        inBuffer.write(FileAct.readAll());
        query->bindValue(":CONTENT_CONTENT", inByteArray);
        QPixmap* pixmap = new QPixmap();
        pixmap->loadFromData(inByteArray);
        pixmap = new QPixmap(pixmap->scaled(QSize(200, 200), Qt::KeepAspectRatio));
        QByteArray inByteArrayScale;
        QBuffer inBufferScale( &inByteArrayScale );
        inBufferScale.open(QIODevice::WriteOnly);
        pixmap->save(&inBufferScale, "PNG");
        query->bindValue(":SCALED_CONTENT", inByteArrayScale);
        query->bindValue(":EXTENSION_CONTENT", file->suffix());
        if (!query->exec()){
            emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
            qDebug() << query->lastError();
            return false;
        }
        query->first();
        QSqlRecord rec = query->record();
        idFILE = query->value(rec.indexOf("id")).toInt();

        query->clear();

        query->prepare("INSERT INTO USERS (file_id, last_name, first_name, otch, login, hashedpassword, email) VALUES (:file_id, :last_name, :first_name, :otch, :login, :hashedpassword, :email) RETURNING id_user as id");
        query->bindValue(":file_id", idFILE);
        query->bindValue(":first_name", firstname);
        query->bindValue(":file_id", idFILE);
        query->bindValue(":last_name", lastname);
        query->bindValue(":otch", otch);
        query->bindValue(":login", login);
        query->bindValue(":hashedpassword", makeHash(password));
        query->bindValue(":email", email);
    }
    else{
        query->prepare("INSERT INTO USERS (last_name, first_name, otch, login, hashedpassword, email) VALUES (:last_name, :first_name, :otch, :login, :hashedpassword, :email) RETURNING id_user as id");
        query->bindValue(":last_name", lastname);
        query->bindValue(":first_name", firstname);
        query->bindValue(":otch", otch);
        query->bindValue(":login", login);
        query->bindValue(":hashedpassword", makeHash(password));
        query->bindValue(":email", email);
    }
    if (!query->exec()){
        emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
        qDebug() << query->lastError();
        return false;
    }
    query->first();
    QSqlRecord rec2 = query->record();
    currentUserId = query->value(rec2.indexOf("id")).toInt();
    ChangeimagePath.clear();
    query->clear();
    emit workProcessError("Регистрация прошла успешно");
    RememberAuth(login, password);
    return true;
}

bool ProjectManager::setChangeImagePath(QString path)
{
    QFileInfo* file = new QFileInfo(path.remove(0, 8));
    QRegExp* exp = new QRegExp("png|PNG|jpg|JPG|JPEG|jpeg");
    if (path == ""){
        ChangeimagePath = path;
        emit ChangeimagePathChanged();
        return true;
    }
    if(file->exists() && file->isReadable()){
        if(exp->exactMatch(file->suffix())){
            if(file->size() < 8388608){
                ChangeimagePath = path;
                emit ChangeimagePathChanged();
                return true;
            }
            else{
                emit workProcessError("Загруженный файл имеет размер \n больше максимально доступного (8МБ)");
                return false;
            }
        }
        else{
            emit workProcessError("Загруженный файл имеет неверный формат" );
            return false;
        }
    }
    else{
        emit workProcessError("Непредвиденная ошибка связанная \n с загруженным файлом");
        return false;
    }
}



bool ProjectManager::sendEmailCode(QString lastname, QString firstname, QString otch, QString login, QString email, QString password)
{
    if (lastname == "" || firstname == "" || login == "" || email == "" || password == ""){
        emit workProcessError("Не были введены необходимые данные\n Для ввода обязательны все данные, кроме Отчества");
        return false;
    }
    QString emailRegEx = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,6}$";
    QRegExp* exp = new QRegExp(emailRegEx);
    if (exp->exactMatch(email)){
        query->prepare("select * from users where email = :EMAIL_ACT");
        query->bindValue(":EMAIL_ACT", email);
        if (!query->exec()){
            emit workProcessError("Непредвиденная ошибка связанная \n с подключением");
            return false;
        }
        if (query->next()){
            emit workProcessError("Данная электронная почта занята другим пользователем");
            return false;
        }
        Smtp* smtp = new Smtp("smtpmail123456@mail.ru", "yPy2tX4eyH9DDaqMCcpe", "smtp.mail.ru", 465);
        QString code = "";
        for (int i = 0; i < 10; i++){
            code.append(QString::number(QRandomGenerator::global()->bounded(0, 9)));
        }
        connect(smtp, SIGNAL(status(QString)), this, SLOT(workProcessError(QString)));
        smtp->sendMail("smtpmail123456@mail.ru", email, "Код для регистрации в приложении", "Код для регистрации в приложении: " + code);
        emailCode = code;
        return true;
    }
    else{
        emit workProcessError("Введённый email - некорректный");
        return false;
    }
}

bool ProjectManager::authUser(QString logemail, QString password)
{
    query->prepare("select id_user, hashedpassword from users where (email = :EMAIL_LOG or login = :EMAIL_LOG2)");
    query->bindValue(":EMAIL_LOG", logemail);
    query->bindValue(":EMAIL_LOG2", logemail);
    if (!query->exec()){
        emit workProcessError("Непредвиденная ошибка связанная \n с подключением");
        qDebug() << query->lastError();
        return false;
    }
    if (query->next()){
        QSqlRecord rec = query->record();

        if (query->value(rec.indexOf("hashedpassword")).toString() == makeHash(password)){
            currentUserId = query->value(rec.indexOf("id_user")).toInt();
            RememberAuth(logemail, password);
            return true;
        }
        else{
            emit workProcessError("Логин/Email или пароль были неправильными");
            return false;
        }
    }
    emit workProcessError("Логин/Email или пароль были неправильными");
    return false;
}

bool ProjectManager::authThroughtSettings(QString login, QString password)
{
    query->prepare("select id_user, hashedpassword from users where (email = :EMAIL_LOG or login = :EMAIL_LOG2)");
    query->bindValue(":EMAIL_LOG", login);
    query->bindValue(":EMAIL_LOG2", login);
    if (!query->exec()){
        return false;
    }
    if (query->next()){
        QSqlRecord rec = query->record();
        if (query->value(rec.indexOf("hashedpassword")).toString() == password){
            currentUserId = query->value(rec.indexOf("id_user")).toInt();
            return true;
        }
    }
    return false;
}

void ProjectManager::RememberAuth(QString login, QString password)
{
    SettingsFileManager* settings =  new SettingsFileManager();
    if (login != "")
        settings->write("login", login);
    if (password != ""){
        settings->write("password", makeHash(password));
    }
    settings->deleteLater();
}

QString ProjectManager::makeHash(QString hashtarget)
{
    QCryptographicHash hash (QCryptographicHash::Sha3_512);
    hash.addData(hashtarget.toUtf8());
    return hash.result().toHex();
}

void ProjectManager::resetEmailCode()
{
    emailCode = "";
}

bool ProjectManager::sendResetEmailCode(QString email)
{
    QString emailRegEx = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,6}$";
    QRegExp* exp = new QRegExp(emailRegEx);
    if (exp->exactMatch(email)){
        query->prepare("select id_user from users where email = :EMAIL_ACT");
        query->bindValue(":EMAIL_ACT", email);
        if (!query->exec()){
            emit workProcessError("Непредвиденная ошибка связанная \n с подключением");
            return false;
        }
        if (query->next()){
            currentUserId = query->value(query->record().indexOf("id_user")).toInt();
            Smtp* smtp = new Smtp("smtpmail123456@mail.ru", "yPy2tX4eyH9DDaqMCcpe", "smtp.mail.ru", 465);
            QString code = "";
            for (int i = 0; i < 10; i++){
                code.append(QString::number(QRandomGenerator::global()->bounded(0, 9)));
            }
            connect(smtp, SIGNAL(status(QString)), this, SLOT(workProcessError(QString)));
            smtp->sendMail("smtpmail123456@mail.ru", email, "Код для востановления пароля", "Код для востановления пароля в приложении: " + code);
            emailCode = code;
            return true;
        }
        else{
            emit workProcessError("Введённый email не пренадлежит не одному аккаунту");
            return false;
        }
    }
    else{
        emit workProcessError("Введённый email - некорректный");
        return false;
    }
}

bool ProjectManager::resetPassword(QString password, QString emailCodeWrite, QString email)
{
    QString passwordRegEx = "^(?=.*[0-9])(?=.*[!@#$%^&*])(?=.*[a-z])(?=.*[A-Z])[0-9a-zA-Z!@#$%^&*]{8,30}$";
    QRegExp* exp = new QRegExp(passwordRegEx);
    if (!exp->exactMatch(password)){
        emit workProcessError("Введённый пароль - некорректный\n Требования к паролю:\n Как минимум 1 заглавная буква,\n1 прописная буква,\n1 цифра и 1 спец. символ (!@#$%^&*)\n Размер от 8 до 30 символов");
        return false;
    }
    if (emailCode != emailCodeWrite){
        emit workProcessError("Введённый код - неверный");
        return false;
    }
    query->prepare("update users set hashedpassword = :PASS where id_user = :USER");
    query->bindValue(":PASS", makeHash(password));
    query->bindValue(":USER", currentUserId);
    if (!query->exec()){
        emit workProcessError("Непредвиденная ошибка связанная \n с подключением");
        qDebug() << query->lastError();
        return false;
    }
    RememberAuth(email, password);
    return true;
}

bool ProjectManager::createConversation(QString name)
{
    if (name == ""){
        emit workProcessError("Название беседы не может быть пустым");
        return false;
    }
    int idFILE;
    if (ChangeimagePath != nullptr && ChangeimagePath != ""){
        QFileInfo* file = new QFileInfo(ChangeimagePath);
        query->prepare("INSERT INTO files (file_name, file_content, file_content_imagescaled, file_extension) VALUES (:NAME_CONTENT, :CONTENT_CONTENT, :SCALED_CONTENT, :EXTENSION_CONTENT) RETURNING id_file as id");
        query->bindValue(":NAME_CONTENT", file->completeBaseName());
        QFile FileAct(file->absoluteFilePath());
        if (!FileAct.exists()){
            emit workProcessError("Непредвиденная ошибка связанная с файлом загруженной фотографии");
            return false;
        }
        QByteArray inByteArray;
        QBuffer inBuffer( &inByteArray );
        inBuffer.open( QIODevice::WriteOnly);
        FileAct.open(QIODevice::ReadOnly);
        inBuffer.write(FileAct.readAll());
        query->bindValue(":CONTENT_CONTENT", inByteArray);
        QPixmap* pixmap = new QPixmap();
        pixmap->loadFromData(inByteArray);
        pixmap = new QPixmap(pixmap->scaled(QSize(200, 200), Qt::KeepAspectRatio));
        QByteArray inByteArrayScale;
        QBuffer inBufferScale( &inByteArrayScale );
        inBufferScale.open(QIODevice::WriteOnly);
        pixmap->save(&inBufferScale, "PNG");
        query->bindValue(":SCALED_CONTENT", inByteArrayScale);
        query->bindValue(":EXTENSION_CONTENT", file->suffix());
        if (!query->exec()){
            emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
            qDebug() << query->lastError();
            return false;
        }
        query->first();
        QSqlRecord rec = query->record();
        idFILE = query->value(rec.indexOf("id")).toInt();
        query->clear();

        query->prepare("INSERT INTO Chat (file_id, name_chat, create_date) VALUES (:file_id, :name, now()) returning id_chat");
        query->bindValue(":file_id", idFILE);
        query->bindValue(":name", name);
    }
    else{
        query->prepare("INSERT INTO Chat (name_chat, create_date) VALUES (:name, now()) returning id_chat");
        query->bindValue(":name", name);
    }
    if (!query->exec()){
        emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
        qDebug() << query->lastError();
        return false;
    }
    query->first();
    QSqlRecord rec2 = query->record();
    int id_chat = query->value(rec2.indexOf("id_chat")).toInt();
    query->clear();
    query->prepare("INSERT INTO chat_user (user_id, chat_id, user_chat_status, is_creator) values (:user, :chat, true, true)");
    query->bindValue(":chat", id_chat);
    query->bindValue(":user", currentUserId);
    if (!query->exec()){
        emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
        qDebug() << query->lastError();
        return false;
    }
    return true;
}

QSortFilterProxyModel *ProjectManager::getConversations(QString search)
{
    convSearchFilter = search;
    convModel = new VariantMapTableModel();
    QSqlQueryModel* model = new QSqlQueryModel();
    QString que = "select id_chat_user, id_chat, user_id, name_chat, chatfile.file_content_imagescaled  as chatphoto, userfile.file_content_imagescaled as userphoto, content_message, date_message, messages.is_sticker  from chat_user inner join chat on id_chat = chat_id left join messages on id_message in (SELECT MAX(id_message) from messages where chat_user_id in (select id_chat_user from chat_user where chat_id = id_chat and user_id not in (select userban_id from banlist where user_id = %1))) left join users as sender on id_user = (SELECT user_id from chat_user where id_chat_user = chat_user_id) left join files as chatfile on chatfile.id_file = chat.file_id left join files as userfile on userfile.id_file = sender.file_id  where user_id = %2 and name_chat like '%' || '%3' || '%' and user_chat_status = true ORDER BY id_message DESC";
    model->setQuery(que.arg(currentUserId).arg(currentUserId).arg(search), base);
    for (int i = 0; i < model->columnCount(); i++){
        convModel->registerColumn(new SimpleColumn(model->headerData(i, Qt::Horizontal, Qt::DisplayRole).toString()));
    }
    convModel->registerColumn(new SimpleColumn("date_sort"));
    for(int i = 0; i < model->rowCount(); i++){
        QVariantMap item;
        item.insert("id", model->record(i).value(0).toString());
        item.insert(model->headerData(0, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(0).toString());
        item.insert(model->headerData(1, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(1).toString());
        item.insert(model->headerData(2, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(2).toString());
        item.insert(model->headerData(3, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(3).toString());
        item.insert(model->headerData(4, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(4));
        item.insert(model->headerData(5, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(5));
        if (model->record(i).value(8).toString() == "false")
            item.insert(model->headerData(6, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(6).toString().replace("\n", " "));
        else if (model->record(i).value(6).toString() != "")
            item.insert(model->headerData(6, Qt::Horizontal, Qt::DisplayRole).toString(), "Стикер");
        else
            item.insert(model->headerData(6, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(6).toString().replace("\n", " "));
        item.insert(model->headerData(7, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(7).toString().replace('T', ' ').left(16));
        item.insert("date_sort", model->record(i).value(7).toString().replace('T', ' ').left(19));
        convModel->addRow(item);
    }
    proxyConv = new QSortFilterProxyModel();
    proxyConv->setSourceModel(convModel);
    proxyConv->sort(9, Qt::DescendingOrder);
    return proxyConv;
}

QString ProjectManager::getImageBytes(QByteArray content)
{
    return QString::fromLatin1("data:image/png;base64,") + QString::fromLatin1(content.toBase64().data());
}

void ProjectManager::addToConvList(QString id, QString status)
{
    if(status == "false"){
        convModel->removeRow(convModel->rowById(id.toInt()), QModelIndex());
        return;
    }
    QSqlQueryModel* model = new QSqlQueryModel();
    QString que = "select id_chat_user, id_chat, user_id, name_chat, chatfile.file_content_imagescaled  as chatphoto, userfile.file_content_imagescaled as userphoto, content_message, date_message, messages.is_sticker  from chat_user inner join chat on id_chat = chat_id left join messages on id_message in (SELECT MAX(id_message) from messages where chat_user_id in (select id_chat_user from chat_user where chat_id = id_chat and user_id not in (select userban_id from banlist where user_id = %1))) left join users as sender on id_user = (SELECT user_id from chat_user where id_chat_user = chat_user_id) left join files as chatfile on chatfile.id_file = chat.file_id left join files as userfile on userfile.id_file = sender.file_id where id_chat_user = %2 and name_chat like '%' || '%3' || '%' and user_chat_status = true";
    model->setQuery(que.arg(currentUserId).arg(id).arg(convSearchFilter), base);
    QVariantMap item;
    if(model->record(0).value(0).toString() == ""){
        return;
    }
    item.insert("id", model->record(0).value(0).toString());
    item.insert(model->headerData(0, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(0).value(0).toString());
    item.insert(model->headerData(1, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(0).value(1).toString());
    item.insert(model->headerData(2, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(0).value(2).toString());
    item.insert(model->headerData(3, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(0).value(3).toString());
    item.insert(model->headerData(4, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(0).value(4));
    item.insert(model->headerData(5, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(0).value(5));
    if (model->record(0).value(8).toString() == "false")
        item.insert(model->headerData(6, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(0).value(6).toString().replace("\n", " "));
    else if (model->record(0).value(6).toString() != "")
        item.insert(model->headerData(6, Qt::Horizontal, Qt::DisplayRole).toString(), "Стикер");
    else
        item.insert(model->headerData(6, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(0).value(6).toString().replace("\n", " "));
    item.insert(model->headerData(7, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(0).value(7).toString().replace('T', ' ').left(16));
    item.insert("date_sort", model->record(0).value(7).toString().replace('T', ' ').left(19));
    convModel->addRow(item);
    proxyConv->sort(9, Qt::DescendingOrder);
}

void ProjectManager::resetConvFilter()
{
    convSearchFilter = "";
}

VariantMapTableModel *ProjectManager::getUsers(QString search)
{
    VariantMapTableModel* Model = new VariantMapTableModel();
    QSqlQueryModel* model = new QSqlQueryModel();
    QString que = "select id_user, last_name, first_name, otch, file_content_imagescaled, email from users left join files on file_id = id_file where id_user != %1 and (last_name || ' ' || first_name || ' ' || otch || ' ' || email) like '%' || '%2' || '%'";
    model->setQuery(que.arg(currentUserId).arg(search), base);
    for (int i = 0; i < model->columnCount(); i++){
        Model->registerColumn(new SimpleColumn(model->headerData(i, Qt::Horizontal, Qt::DisplayRole).toString()));
    }
    for(int i = 0; i < model->rowCount(); i++){
        QVariantMap item;
        item.insert("id", model->record(i).value(0).toString());
        item.insert(model->headerData(0, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(0).toString());
        item.insert(model->headerData(1, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(1).toString());
        item.insert(model->headerData(2, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(2).toString());
        item.insert(model->headerData(3, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(3).toString());
        item.insert(model->headerData(4, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(4));
        item.insert(model->headerData(5, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(5).toString());
        Model->addRow(item);
    }
    return Model;
}


VariantMapTableModel *ProjectManager::getBanedUsers(QString search)
{
    banModel = new VariantMapTableModel();
    QSqlQueryModel* model = new QSqlQueryModel();
    QString que = "select id_banlist, userban_id, last_name, first_name, otch, email, file_content_imagescaled from banlist inner join users on id_user = userban_id left join files on id_file = file_id where user_id = %1 and (last_name || ' ' || first_name || ' ' || otch || ' ' || email) like '%' || '%2' || '%'";
    model->setQuery(que.arg(currentUserId).arg(search), base);
    for (int i = 0; i < model->columnCount(); i++){
        banModel->registerColumn(new SimpleColumn(model->headerData(i, Qt::Horizontal, Qt::DisplayRole).toString()));
    }
    for(int i = 0; i < model->rowCount(); i++){
        QVariantMap item;
        item.insert("id", model->record(i).value(0).toString());
        item.insert(model->headerData(0, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(0).toString());
        item.insert(model->headerData(1, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(1).toString());
        item.insert(model->headerData(2, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(2).toString());
        item.insert(model->headerData(3, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(3).toString());
        item.insert(model->headerData(4, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(4).toString());
        item.insert(model->headerData(5, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(5).toString());
        item.insert(model->headerData(6, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(6));
        banModel->addRow(item);
    }
    return banModel;
}


bool ProjectManager::getUserData(int id_user)
{
    userdata = QStringList();
    query->prepare("select file_content, last_name, first_name, otch, email, login from users left join files on id_file = file_id where id_user = :USER");
    if (id_user == -1)
        query->bindValue(":USER", currentUserId);
    else
        query->bindValue(":USER", id_user);
    if (!query->exec()){
        emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
        return false;
    }
    if(!query->first()){
        emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
        return false;
    }
    QSqlRecord rec2 = query->record();
    QByteArray content = query->value(rec2.indexOf("file_content")).toByteArray();
    if (content != ""){
        userdata.append(getImageBytes(content));
    }
    else{
        userdata.append(content);
    }
    userdata.append(query->value(rec2.indexOf("last_name")).toString());
    userdata.append(query->value(rec2.indexOf("first_name")).toString());
    userdata.append(query->value(rec2.indexOf("otch")).toString());
    userdata.append(query->value(rec2.indexOf("email")).toString());
    userdata.append(query->value(rec2.indexOf("login")).toString());
    return true;
}

QStringList ProjectManager::getUserDataList() const
{
    return userdata;
}

bool ProjectManager::setNewFIO(QString lastname, QString firstname, QString otch)
{
    if(lastname == "" || firstname == ""){
        emit workProcessError("Были введены некорректные данные");
        return false;
    }
    if (ChangeimagePath == ""){
        query->prepare("update users set last_name = :LASTNAME, first_name = :FIRSTNAME, otch = :OTCH where id_user = :ID");
        query->bindValue(":LASTNAME", lastname);
        query->bindValue(":FIRSTNAME", firstname);
        query->bindValue(":OTCH", otch);
        query->bindValue(":ID", currentUserId);
        if (!query->exec()){
            emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
            return false;
            qDebug() << query->lastError();
        }
    }
    else{
        QFileInfo* file = new QFileInfo(ChangeimagePath);
        query->prepare("INSERT INTO files (file_name, file_content, file_content_imagescaled, file_extension) VALUES (:NAME_CONTENT, :CONTENT_CONTENT, :SCALED_CONTENT, :EXTENSION_CONTENT) RETURNING id_file as id");
        query->bindValue(":NAME_CONTENT", file->completeBaseName());
        QFile FileAct(file->absoluteFilePath());
        if (!FileAct.exists()){
            emit workProcessError("Непредвиденная ошибка связанная с файлом аватара профиля");
            return false;
        }
        QByteArray inByteArray;
        QBuffer inBuffer( &inByteArray );
        inBuffer.open( QIODevice::WriteOnly);
        FileAct.open(QIODevice::ReadOnly);
        inBuffer.write(FileAct.readAll());
        query->bindValue(":CONTENT_CONTENT", inByteArray);
        QPixmap* pixmap = new QPixmap();
        pixmap->loadFromData(inByteArray);
        pixmap = new QPixmap(pixmap->scaled(QSize(200, 200), Qt::KeepAspectRatio));
        QByteArray inByteArrayScale;
        QBuffer inBufferScale( &inByteArrayScale );
        inBufferScale.open(QIODevice::WriteOnly);
        pixmap->save(&inBufferScale, "PNG");
        query->bindValue(":SCALED_CONTENT", inByteArrayScale);
        query->bindValue(":EXTENSION_CONTENT", file->suffix());
        if (!query->exec()){
            emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
            qDebug() << query->lastError();
            return false;
        }
        query->first();
        QSqlRecord rec = query->record();
        int idFILE = query->value(rec.indexOf("id")).toInt();
        query->clear();
        query->prepare("update users set last_name = :LASTNAME, first_name = :FIRSTNAME, otch = :OTCH, file_id = :FILE where id_user = :ID");
        query->bindValue(":LASTNAME", lastname);
        query->bindValue(":FIRSTNAME", firstname);
        query->bindValue(":OTCH", otch);
        query->bindValue(":FILE", idFILE);
        query->bindValue(":ID", currentUserId);
        if (!query->exec()){
            emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
            return false;
            qDebug() << query->lastError();
        }
    }
    emit workProcessError("Личные данные были изменены");
    return true;
}

bool ProjectManager::sendChangeEmailCode(QString email)
{
    QString emailRegEx = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,6}$";
    QRegExp* exp = new QRegExp(emailRegEx);
    if (exp->exactMatch(email)){
        query->prepare("select * from users where email = :EMAIL_ACT");
        query->bindValue(":EMAIL_ACT", email);
        if (!query->exec()){
            emit workProcessError("Непредвиденная ошибка связанная \n с подключением");
            return false;
        }
        if (query->next()){
            emit workProcessError("Данная электронная почта занята другим пользователем");
            return false;
        }
        Smtp* smtp = new Smtp("smtpmail123456@mail.ru", "yPy2tX4eyH9DDaqMCcpe", "smtp.mail.ru", 465);
        QString code = "";
        for (int i = 0; i < 10; i++){
            code.append(QString::number(QRandomGenerator::global()->bounded(0, 9)));
        }
        connect(smtp, SIGNAL(status(QString)), this, SLOT(workProcessError(QString)));
        smtp->sendMail("smtpmail123456@mail.ru", email, "Код для смены электронной почты в приложении", "Код для смены электронной почты в приложении: " + code);
        emailCode = code;
        return true;
    }
    else{
        emit workProcessError("Введённый email - некорректный");
        return false;
    }
}

bool ProjectManager::setNewEmail(QString email, QString code)
{
    if (code == emailCode){
        query->prepare("update users set email = :EMAIL where id_user = :ID");
        query->bindValue(":EMAIL", email);
        query->bindValue(":ID", currentUserId);
        if (!query->exec()){
            emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
            return false;
            qDebug() << query->lastError();
        }
        emit workProcessError("Электронная почта была изменена");
        RememberAuth(email, "");
        return true;
    }
    else{
        emit workProcessError("Введённый кон - неверный");
        return false;
    }
}

bool ProjectManager::setNewPassLog(QString login, QString oldpass, QString newpass, QString reppass)
{
    if (newpass == reppass){
        query->prepare("select hashedpassword from users where id_user = :USER");
        query->bindValue(":USER", currentUserId);
        if (!query->exec()){
            emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
            return false;
        }
        query->first();
        if (query->value(query->record().indexOf("hashedpassword")).toString() != makeHash(oldpass)){
            emit workProcessError("Неправильный пароль");
            return false;
        }
        query->clear();
        QString passwordRegEx = "^(?=.*[0-9])(?=.*[!@#$%^&*])(?=.*[a-z])(?=.*[A-Z])[0-9a-zA-Z!@#$%^&*]{8,30}$";
        QRegExp* exp = new QRegExp(passwordRegEx);
        if (!exp->exactMatch(newpass)){
            emit workProcessError("Введённый пароль - некорректный\n Требования к паролю:\n Как минимум 1 заглавная буква,\n1 прописная буква,\n1 цифра и 1 спец. символ (!@#$%^&*)\n Размер от 8 до 30 символов");
            return false;
        }
        query->prepare("select id_user from users where login = :LOGIN_ACT");
        query->bindValue(":LOGIN_ACT", login);
        if (!query->exec()){
            emit workProcessError("Непредвиденная ошибка связанная \n с подключением");
            return false;
        }
        if (login == ""){
            emit workProcessError("Логин не может быть пустым");
            return false;
        }
        if (query->next() && login != userdata[5]){
            emit workProcessError("Данный логин занят другим пользователем");
            return false;
        }

        query->prepare("update users set login = :LOGIN, hashedpassword = :PASS where id_user = :ID");
        query->bindValue(":LOGIN", login);
        query->bindValue(":PASS", makeHash(newpass));
        query->bindValue(":ID", currentUserId);
        if (!query->exec()){
            emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
            return false;
        }
        emit workProcessError("Логин и пароль были изменены");
        RememberAuth(login, newpass);
        return true;
    }
    else{
        emit workProcessError("Введённые пароли не совпадают");
        return false;
    }
}

bool ProjectManager::isBlocked(int id_user)
{
    query->prepare("select id_banlist from banlist where user_id = :IDU and userban_id = :IDB");
    query->bindValue(":IDU", currentUserId);
    query->bindValue(":IDB", id_user);
    if (!query->exec()){
        emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
        qDebug() << query->lastError();
        return true;
    }
    if(query->next()){
        return true;
    }
    return false;
}

bool ProjectManager::isIBlocked(int id_user)
{
    query->prepare("select id_banlist from banlist where user_id = :IDU and userban_id = :IDB");
    query->bindValue(":IDU", id_user);
    query->bindValue(":IDB", currentUserId);
    if (!query->exec()){
        emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
        qDebug() << query->lastError();
        return true;
    }
    if(query->next()){
        return true;
    }
    return false;
}

bool ProjectManager::blockUser(int id)
{
    query->prepare("select id_banlist from banlist where user_id = :IDU and userban_id = :IDB");
    query->bindValue(":IDU", currentUserId);
    query->bindValue(":IDB", id);
    if (!query->exec()){
        emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
        qDebug() << query->lastError();
        return false;
    }
    if(query->next()){
        emit workProcessError("Данный пользователь был заблокирован ранее");
        return true;
    }
    query->prepare("insert into banlist (user_id, userban_id, add_date) values (:IDU, :IDB, now())");
    query->bindValue(":IDU", currentUserId);
    query->bindValue(":IDB", id);
    if (!query->exec()){
        emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
        qDebug() << query->lastError();
        return false;
    }
    emit workProcessError("Пользователь был заблокирован");
    return true;
}

bool ProjectManager::restoreUser(int id, int rowid)
{
    query->prepare("select id_banlist from banlist where user_id = :IDU and userban_id = :IDB");
    query->bindValue(":IDU", currentUserId);
    query->bindValue(":IDB", id);
    if (!query->exec()){
        emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
        qDebug() << query->lastError();
        return false;
    }
    if(!query->first()){
        emit workProcessError("Данный пользователь не заблокирован");
        if(isRefreshBanedNeeded)
            banModel->removeRow(banModel->rowById(rowid), QModelIndex());
        return true;
    }
    int id_ban = query->value(query->record().indexOf("id_banlist")).toInt();
    query->prepare("delete from banlist where id_banlist = :BAN");
    query->bindValue(":BAN", id_ban);
    if (!query->exec()){
        emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
        qDebug() << query->lastError();
        return false;
    }
    if(isRefreshBanedNeeded)
        banModel->removeRow(banModel->rowById(id_ban), QModelIndex());
    emit workProcessError("Пользователь был разблокирован");
    return true;
}

bool ProjectManager::createPersonalConv(int id, QString name)
{
    if (name == ""){
        emit workProcessError("Название беседы не может быть пустым");
        return false;
    }
    int idFILE;
    if (ChangeimagePath != nullptr && ChangeimagePath != ""){
        QFileInfo* file = new QFileInfo(ChangeimagePath);
        query->prepare("INSERT INTO files (file_name, file_content, file_content_imagescaled, file_extension) VALUES (:NAME_CONTENT, :CONTENT_CONTENT, :SCALED_CONTENT, :EXTENSION_CONTENT) RETURNING id_file as id");
        query->bindValue(":NAME_CONTENT", file->completeBaseName());
        QFile FileAct(file->absoluteFilePath());
        if (!FileAct.exists()){
            emit workProcessError("Непредвиденная ошибка связанная с файлом загруженной фотографии");
            return false;
        }
        QByteArray inByteArray;
        QBuffer inBuffer( &inByteArray );
        inBuffer.open( QIODevice::WriteOnly);
        FileAct.open(QIODevice::ReadOnly);
        inBuffer.write(FileAct.readAll());
        query->bindValue(":CONTENT_CONTENT", inByteArray);
        QPixmap* pixmap = new QPixmap();
        pixmap->loadFromData(inByteArray);
        pixmap = new QPixmap(pixmap->scaled(QSize(200, 200), Qt::KeepAspectRatio));
        QByteArray inByteArrayScale;
        QBuffer inBufferScale( &inByteArrayScale );
        inBufferScale.open(QIODevice::WriteOnly);
        pixmap->save(&inBufferScale, "PNG");
        query->bindValue(":SCALED_CONTENT", inByteArrayScale);
        query->bindValue(":EXTENSION_CONTENT", file->suffix());
        if (!query->exec()){
            emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
            qDebug() << query->lastError();
            return false;
        }
        query->first();
        QSqlRecord rec = query->record();
        idFILE = query->value(rec.indexOf("id")).toInt();
        query->clear();

        query->prepare("INSERT INTO Chat (file_id, name_chat, create_date) VALUES (:file_id, :name, now()) returning id_chat");
        query->bindValue(":file_id", idFILE);
        query->bindValue(":name", name);
    }
    else{
        query->prepare("INSERT INTO Chat (name_chat, create_date) VALUES (:name, now()) returning id_chat");
        query->bindValue(":name", name);
    }
    if (!query->exec()){
        emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
        qDebug() << query->lastError();
        return false;
    }
    query->first();
    QSqlRecord rec2 = query->record();
    int id_chat = query->value(rec2.indexOf("id_chat")).toInt();
    query->prepare("INSERT INTO chat_user (user_id, chat_id, user_chat_status, is_creator) values (:user, :chat, true, false)");
    query->bindValue(":chat", id_chat);
    query->bindValue(":user", id);
    if (!query->exec()){
        emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
        qDebug() << query->lastError();
        return false;
    }
    query->prepare("INSERT INTO chat_user (user_id, chat_id, user_chat_status, is_creator) values (:user, :chat, true, true)");
    query->bindValue(":chat", id_chat);
    query->bindValue(":user", currentUserId);
    if (!query->exec()){
        emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
        qDebug() << query->lastError();
        return false;
    }
    return true;
}

void ProjectManager::setRefreshConv(bool value)
{
    isRefreshConvNeeded = value;
}

void ProjectManager::setRefreshBaned(bool value)
{
    isRefreshBanedNeeded = value;
}

VariantMapTableModel* ProjectManager::getStickers()
{
    QString path = ":/Emoji/";
    QDir* dir = new QDir(path);
    VariantMapTableModel* model = new VariantMapTableModel();
    model->registerColumn(new SimpleColumn("source"));
    for (int i = 0; i < dir->entryList().count(); i++){
        QVariantMap item;
        item.insert("id", i);
        item.insert("source", "qrc" + path + dir->entryList()[i]);
        model->addRow(item);
    }
    return model;
}

VariantMapTableModel *ProjectManager::getUsersForConv(int id_conv)
{
    Chat_Users = new VariantMapTableModel();
    QSqlQueryModel* model = new QSqlQueryModel();
    QString que = "select id_user, last_name, first_name, otch, file_content_imageScaled, chat_user.id_chat_user, email from chat_user inner join users on id_user = user_id left join files as userfile on id_file = users.file_id where chat_id = %1 and user_chat_status = true";
    model->setQuery(que.arg(id_conv), base);
    for (int i = 0; i < model->columnCount(); i++){
        Chat_Users->registerColumn(new SimpleColumn(model->headerData(i, Qt::Horizontal, Qt::DisplayRole).toString()));
    }
    for(int i = 0; i < model->rowCount(); i++){
        QVariantMap item;
        item.insert("id", model->record(i).value(5).toString());
        item.insert(model->headerData(0, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(0).toString());
        item.insert(model->headerData(1, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(1).toString());
        item.insert(model->headerData(2, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(2).toString());
        item.insert(model->headerData(3, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(3).toString());
        item.insert(model->headerData(4, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(4));
        item.insert(model->headerData(5, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(5).toString());
        item.insert(model->headerData(6, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(6).toString());
        Chat_Users->addRow(item);
    }
    return Chat_Users;
}

int ProjectManager::getCurrentUserId() const
{
    return currentUserId;
}

bool ProjectManager::hasConv(int id)
{
    query->prepare("select chat_id from chat_user where user_id = :IDU and chat_id = :IDB and user_chat_status = true");
    query->bindValue(":IDU", currentUserId);
    query->bindValue(":IDB", id);
    if (!query->exec()){
        emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
        qDebug() << query->lastError();
        return false;
    }
    if(!query->first()){
        return false;
    }
    return true;
}

void ProjectManager::getChatData(int id)
{
    query->prepare("select name_chat, file_content_imageScaled from chat left join files on id_file = file_id where id_chat = :ID");
    query->bindValue(":ID", id);
    if (!query->exec()){
        emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
        qDebug() << query->lastError();
        return;
    }
    if(!query->first()){
        emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
        return;
    }
    chatDataList = QStringList();
    QByteArray content = query->value(query->record().indexOf("file_content_imageScaled")).toByteArray();
    chatDataList.append(query->value(query->record().indexOf("name_chat")).toString());
    if (content == "")
        chatDataList.append("");
    else
        chatDataList.append(getImageBytes(content));
}

QStringList ProjectManager::chatData() const
{
    return chatDataList;
}

VariantMapTableModel *ProjectManager::getMessages(int id_chat)
{
    if (!hasConv(id_chat)){
        emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
        return new VariantMapTableModel();
    }
    messages = new VariantMapTableModel();
    QSqlQueryModel* model = new QSqlQueryModel();
    QString que = "select id_message ,id_user, date_message, is_sticker, content_message, last_name, first_name, otch, file_content_ImageScaled  from messages  inner join chat_user as sender on sender.id_chat_user =chat_user_id and sender.id_chat_user in (select id_chat_user from chat_user where user_id not in (select userban_id from banlist where user_id = %1)) inner join users on id_user = sender.user_id left join files on id_file = file_id where chat_id = %2 ORDER BY id_message DESC fetch first 30 rows only";
    model->setQuery(que.arg(currentUserId).arg(id_chat), base);
    for (int i = 0; i < model->columnCount(); i++){
        messages->registerColumn(new SimpleColumn(model->headerData(i, Qt::Horizontal, Qt::DisplayRole).toString()));
    }
    for(int i = model->rowCount()-1; i >= 0; i--){
        QVariantMap item;
        item.insert("id", model->record(i).value(0).toString());
        item.insert(model->headerData(0, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(0).toString());
        item.insert(model->headerData(1, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(1).toString());
        item.insert(model->headerData(2, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(2).toString().replace('T', ' ').left(16));
        item.insert(model->headerData(3, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(3).toString());
        item.insert(model->headerData(4, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(4).toString());
        if (model->record(i).value(7).toString() == "")
            item.insert(model->headerData(5, Qt::Horizontal, Qt::DisplayRole).toString(),  model->record(i).value(5).toString() + " " + model->record(i).value(6).toString().at(0) + ".");
        else
            item.insert(model->headerData(5, Qt::Horizontal, Qt::DisplayRole).toString(),  model->record(i).value(5).toString() + " " + model->record(i).value(6).toString().at(0) + ". " + model->record(i).value(7).toString().at(0) + ".");
        item.insert(model->headerData(8, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(8));
        messages->addRow(item);
    }
    return messages;
}

bool ProjectManager::fetchMessageModel(int id_chat)
{
    if (!hasConv(id_chat)){
        emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
        return false;
    }
    QSqlQueryModel* model = new QSqlQueryModel();
    QString que = "select id_message ,id_user, date_message, is_sticker, content_message, last_name, first_name, otch, file_content_ImageScaled  from messages  inner join chat_user as sender on sender.id_chat_user =chat_user_id and sender.id_chat_user in (select id_chat_user from chat_user where user_id not in (select userban_id from banlist where user_id = %1)) inner join users on id_user = sender.user_id left join files on id_file = file_id where chat_id = %2 and id_message < %3 ORDER BY id_message DESC fetch first 30 rows only";
    model->setQuery(que.arg(currentUserId).arg(id_chat).arg(messages->idByRow(0)), base);
    qDebug() << model->rowCount();
    for(int i = 0; i < model->rowCount(); i++){
        QVariantMap item;
        item.insert("id", model->record(i).value(0).toString());
        item.insert(model->headerData(0, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(0).toString());
        item.insert(model->headerData(1, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(1).toString());
        item.insert(model->headerData(2, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(2).toString().replace('T', ' ').left(16));
        item.insert(model->headerData(3, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(3).toString());
        item.insert(model->headerData(4, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(4).toString());
        if (model->record(i).value(7).toString() == "")
            item.insert(model->headerData(5, Qt::Horizontal, Qt::DisplayRole).toString(),  model->record(i).value(5).toString() + " " + model->record(i).value(6).toString().at(0) + ".");
        else
            item.insert(model->headerData(5, Qt::Horizontal, Qt::DisplayRole).toString(),  model->record(i).value(5).toString() + " " + model->record(i).value(6).toString().at(0) + ". " + model->record(i).value(7).toString().at(0) + ".");
        item.insert(model->headerData(8, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(8));
        messages->insertRowAtTheBegining(item);
    }
    qDebug() << messages->rowCount(QModelIndex());
    return model->rowCount() != 0;
}

bool ProjectManager::isCreator(int id)
{
    query->prepare("select is_Creator from chat_user where chat_id = :ID and user_id = :IDC");
    query->bindValue(":ID", id);
    query->bindValue(":IDC", currentUserId);
    if (!query->exec()){
        emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
        qDebug() << query->lastError();
        return false;
    }
    if(!query->first()){
        emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
        return false;
    }
    return query->value(query->record().indexOf("is_Creator")).toBool();
}

void ProjectManager::exitConv(int id)
{
    query->prepare("update chat_user set user_chat_status = false where user_id = :IDU and chat_id = :IDC");
    query->bindValue(":IDC", id);
    query->bindValue(":IDU", currentUserId);
    if (!query->exec()){
        emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
        qDebug() << query->lastError();
    }
}

void ProjectManager::setCurrentConversation(int id)
{
    CurrentConversation = id;
}

void ProjectManager::deleteUserFromConv(int id)
{
    query->prepare("update chat_user set user_chat_status = false where id_chat_user = :IDC");
    query->bindValue(":IDC", id);
    if (!query->exec()){
        emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
        qDebug() << query->lastError();
    }
    emit workProcessError("Пользователь успешно удалён");
    Chat_Users->removeRow(Chat_Users->rowById(id), QModelIndex());
}

void ProjectManager::changeChatData(QString name, int id)
{
    if(name == ""){
        emit workProcessError("Название беседы не может быть пустым");
        return;
    }
    query->prepare("select id_chat_user from chat_user where user_id = :IDU and chat_id = :IDB and user_chat_status = true");
    query->bindValue(":IDU", currentUserId);
    query->bindValue(":IDB", id);
    if (!query->exec()){
        emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
        qDebug() << query->lastError();
        return;
    }
    if(!query->first()){
        emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
        return;
    }
    int id_chat_user = query->value(query->record().indexOf("id_chat_user")).toInt();
    if (ChangeimagePath == ""){
        query->prepare("update chat set name_chat = :NAME where id_chat = :IDC");
        query->bindValue(":IDC", id);
        query->bindValue(":NAME", name);
        if (!query->exec()){
            emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
            qDebug() << query->lastError();
            return;
        }
        convModel->setData(convModel->index(convModel->rowById(id_chat_user), 3, QModelIndex()), name, Qt::EditRole);
    }
    else{
        QFileInfo* file = new QFileInfo(ChangeimagePath);
        query->prepare("INSERT INTO files (file_name, file_content, file_content_imagescaled, file_extension) VALUES (:NAME_CONTENT, :CONTENT_CONTENT, :SCALED_CONTENT, :EXTENSION_CONTENT) RETURNING id_file as id");
        query->bindValue(":NAME_CONTENT", file->completeBaseName());
        QFile FileAct(file->absoluteFilePath());
        if (!FileAct.exists()){
            emit workProcessError("Непредвиденная ошибка связанная с файлом загруженной фотографии");
            return;
        }
        QByteArray inByteArray;
        QBuffer inBuffer( &inByteArray );
        inBuffer.open( QIODevice::WriteOnly);
        FileAct.open(QIODevice::ReadOnly);
        inBuffer.write(FileAct.readAll());
        query->bindValue(":CONTENT_CONTENT", inByteArray);
        QPixmap* pixmap = new QPixmap();
        pixmap->loadFromData(inByteArray);
        pixmap = new QPixmap(pixmap->scaled(QSize(200, 200), Qt::KeepAspectRatio));
        QByteArray inByteArrayScale;
        QBuffer inBufferScale( &inByteArrayScale );
        inBufferScale.open(QIODevice::WriteOnly);
        pixmap->save(&inBufferScale, "PNG");
        query->bindValue(":SCALED_CONTENT", inByteArrayScale);
        query->bindValue(":EXTENSION_CONTENT", file->suffix());
        if (!query->exec()){
            emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
            qDebug() << query->lastError();
            return;
        }
        query->first();
        QSqlRecord rec = query->record();
        int idFILE = query->value(rec.indexOf("id")).toInt();
        query->clear();
        query->prepare("update chat set name_chat = :NAME, file_id = :FILE where id_chat = :IDC");
        query->bindValue(":IDC", id);
        query->bindValue(":NAME", name);
        query->bindValue(":FILE", idFILE);
        if (!query->exec()){
            emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
            qDebug() << query->lastError();
            return;
        }
        convModel->setData(convModel->index(convModel->rowById(id_chat_user), 3, QModelIndex()), name, Qt::EditRole);
        convModel->setData(convModel->index(convModel->rowById(id_chat_user), 4, QModelIndex()), inByteArrayScale, Qt::EditRole);
    }
}

bool ProjectManager::addToUserConv(int id_user, int id_conv)
{
    if (!hasConv(id_conv)){
        emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
        return new VariantMapTableModel();
    }
    if (isBlocked(id_user)){
        emit workProcessError("Этот пользователь находиться\n в вашем чёрном списке\nВы не можете добавить его в беседу");
        return false;
    }
    if (isIBlocked(id_user)){
        emit workProcessError("Этот пользователь добавил вас\n в свой чёрный список\nВы не можете добавить его в беседу");
        return false;
    }
    query->prepare("select user_chat_status from chat_user where user_id = :IDU and chat_id = :IDC");
    query->bindValue(":IDC", id_conv);
    query->bindValue(":IDU", id_user);
    if (!query->exec()){
        emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
        qDebug() << query->lastError();
        return false;
    }
    if (query->first()){
        if (query->value(query->record().indexOf("user_chat_status")).toBool()){
            emit workProcessError("Данный пользователь уже состоит в этой беседе");
            return false;
        }
        else{
            query->prepare("update chat_user set user_chat_status = true where user_id = :IDU and chat_id = :IDC");
            query->bindValue(":IDC", id_conv);
            query->bindValue(":IDU", id_user);
            if (!query->exec()){
                emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
                qDebug() << query->lastError();
                return false;
            }
            emit workProcessError("Пользователь успешно добавлен");
            return true;
        }
    }
    query->prepare("INSERT INTO chat_user (user_id, chat_id, user_chat_status, is_creator) values (:user, :chat, true, false)");
    query->bindValue(":chat", id_conv);
    query->bindValue(":user", id_user);
    if (!query->exec()){
        emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
        qDebug() << query->lastError();
        return false;
    }
    emit workProcessError("Пользователь успешно добавлен");
    return true;
}

VariantMapTableModel *ProjectManager::getMessageFiles(int id_message)
{
    VariantMapTableModel* files = new VariantMapTableModel();
    QSqlQueryModel* model = new QSqlQueryModel();
    QString que = "select id_files_message,file_name, file_extension, file_content_Imagescaled  from files_message inner join files on id_file = id_files_message where files_message.id_message = %1";
    model->setQuery(que.arg(id_message), base);
    for (int i = 0; i < model->columnCount(); i++){
        files->registerColumn(new SimpleColumn(model->headerData(i, Qt::Horizontal, Qt::DisplayRole).toString()));
    }
    for(int i = 0; i < model->rowCount(); i++){
        QVariantMap item;
        item.insert("id", model->record(i).value(0).toString());
        item.insert(model->headerData(0, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(0).toString());
        item.insert(model->headerData(1, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(1).toString());
        item.insert(model->headerData(2, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(2).toString());
        item.insert(model->headerData(3, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(i).value(3));
        files->addRow(item);
    }
    return files;
}

QString ProjectManager::getFullImage(int id_file)
{
    query->prepare("select file_content from files where id_file = :file");
    query->bindValue(":file", id_file);
    if (!query->exec() || !query->first()){
        emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
        qDebug() << query->lastError();
    }
    QString content = getImageBytes(query->value(query->record().indexOf("file_content")).toByteArray());
    return content;
}

bool ProjectManager::saveFile(QString url, int id_file)
{
    if (url == ""){
        return false;
    }
    query->prepare("select file_content from files where id_file = :file");
    query->bindValue(":file", id_file);
    if (!query->exec() || !query->first()){
        emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
        qDebug() << query->lastError();
        return false;
    }
    QSaveFile filesave(url.remove(0, 8));
    if (filesave.open(QIODevice::WriteOnly))
    {
        filesave.write(query->value(query->record().indexOf("file_content")).toByteArray());
        filesave.commit();
    }
    return true;
}

bool ProjectManager::sendSticker(int id, QString content)
{
    query->prepare("select id_chat_user from chat_user where id_chat_user = :ID and user_chat_status = true");
    query->bindValue(":ID", id);
    if (!query->exec() || !query->first()){
        emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
        qDebug() << query->lastError();
        return false;
    }
    query->prepare("insert into messages (chat_user_id, content_message, date_message, is_sticker) values (:ID, :content, now(), true)");
    query->bindValue(":ID", id);
    query->bindValue(":content", content);
    if (!query->exec()){
        emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
        qDebug() << query->lastError();
        return false;
    }
    return true;
}

void ProjectManager::addToFiles(QList<QUrl> filesList)
{
    bool hasErrors = false;
    QStringList filesListAct;
    for (int i = 0; i < filesList.count(); i++){
        filesListAct.append(filesList.at(i).toString());
    }
    QString error = "Произошли следующие ошибки, связанные с файлами:";
    if (filesListAct.count() + files->rowCount(QModelIndex()) > 10){
        emit workProcessError("Приложение к сообщению более 10 файлов запрещено");
        return;
    }
    for (int i = 0; i < filesListAct.count(); i++){
        int fileID = -1;
        QFile* file = new QFile(filesListAct[i].remove(0, 8));
        QRegExp* exp = new QRegExp("png|PNG|jpg|JPG|JPEG|jpeg");
        QFileInfo* info = new QFileInfo(filesListAct[i].remove(0, 8));
        if(file->exists()){
            if(file->size() < 8388608){
                if (exp->exactMatch(info->suffix())){
                    query->prepare("INSERT INTO files (file_name, file_content, file_content_imagescaled, file_extension) VALUES (:NAME_CONTENT, :CONTENT_CONTENT, :SCALED_CONTENT, :EXTENSION_CONTENT) RETURNING id_file as id");
                    query->bindValue(":NAME_CONTENT", info->completeBaseName());
                    QByteArray inByteArray;
                    QBuffer inBuffer( &inByteArray );
                    inBuffer.open( QIODevice::WriteOnly);
                    file->open(QIODevice::ReadOnly);
                    inBuffer.write(file->readAll());
                    query->bindValue(":CONTENT_CONTENT", inByteArray);
                    QPixmap* pixmap = new QPixmap();
                    pixmap->loadFromData(inByteArray);
                    pixmap = new QPixmap(pixmap->scaled(QSize(200, 200), Qt::KeepAspectRatio));
                    QByteArray inByteArrayScale;
                    QBuffer inBufferScale( &inByteArrayScale );
                    inBufferScale.open(QIODevice::WriteOnly);
                    pixmap->save(&inBufferScale, "PNG");
                    query->bindValue(":SCALED_CONTENT", inByteArrayScale);
                    query->bindValue(":EXTENSION_CONTENT", info->suffix());
                    if (!query->exec()){
                        emit workProcessError("Непредвиденная ошибка при загрузке одного из файлов\nПопробуйте снова позже");
                        qDebug() << query->lastError();
                        return;
                    }
                    query->first();
                    QSqlRecord rec = query->record();
                    fileID = query->value(rec.indexOf("id")).toInt();
                }
                else{
                    query->prepare("INSERT INTO files (file_name, file_content, file_extension) VALUES (:NAME_CONTENT, :CONTENT_CONTENT, :EXTENSION_CONTENT) RETURNING id_file as id");
                    query->bindValue(":NAME_CONTENT", info->completeBaseName());
                    QByteArray inByteArray;
                    QBuffer inBuffer( &inByteArray );
                    inBuffer.open( QIODevice::WriteOnly);
                    file->open(QIODevice::ReadOnly);
                    inBuffer.write(file->readAll());
                    query->bindValue(":CONTENT_CONTENT", inByteArray);
                    query->bindValue(":EXTENSION_CONTENT", info->suffix());
                    if (!query->exec()){
                        emit workProcessError("Непредвиденная ошибка при загрузке одного из файлов\nПопробуйте снова позже");
                        qDebug() << query->lastError();
                        return;
                    }
                    query->first();
                    QSqlRecord rec = query->record();
                    fileID = query->value(rec.indexOf("id")).toInt();
                }
            }
            else{
                error.append("\n Файл " + info->fileName() + " имеет размер больше 8мб");
                hasErrors = true;
            }
        }
        else{
            error.append("\n Файл " + info->fileName() + " не существует");
            hasErrors = true;
        }
        if(fileID != -1){
            QVariantMap item;
            item.insert("id", fileID);
            item.insert("id_file", fileID);
            item.insert("filename", info->fileName());
            files->addRow(item);
            fileID = -1;
        }
        if(hasErrors){
            emit workProcessError(error);
        }
    }
}

VariantMapTableModel *ProjectManager::getFilesSend()
{
    return files;
}

void ProjectManager::resetFileSend()
{
    files = new VariantMapTableModel();
    files->registerColumn(new SimpleColumn("id_file"));
    files->registerColumn(new SimpleColumn("filename"));
}

void ProjectManager::deleteFile(int id)
{
    files->removeRow(files->rowById(id), QModelIndex());
}

bool ProjectManager::sendMessage(QString message, int id_conv_user)
{
    query->prepare("select id_chat_user from chat_user where id_chat_user = :ID and user_chat_status = true");
    query->bindValue(":ID", id_conv_user);
    if (!query->exec() || !query->first()){
        emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
        qDebug() << query->lastError();
        return false;
    }
    if (message.length() == 0){
        emit workProcessError("Сообщение не может быть пустым");
        return false;
    }
    if (message.length() > 1000){
        emit workProcessError("Сообщение не может быть более 1000 символов");
        return false;
    }
    query->prepare("insert into messages (chat_user_id, content_message, date_message, is_sticker) values (:ID, :content, now(), false) returning id_message");
    query->bindValue(":ID", id_conv_user);
    query->bindValue(":content", message);
    if (!query->exec()){
        emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
        qDebug() << query->lastError();
        return false;
    }
    query->first();
    int id_message = query->value(query->record().indexOf("id_message")).toInt();
    for (int i = 0; i < files->rowCount(QModelIndex()); i++){
        query->prepare("insert into files_message (id_files_message, id_message) values (:FILE, :MESSAGE)");
        query->bindValue(":FILE", files->data(files->index(i, 0), Qt::DisplayRole));
        query->bindValue(":MESSAGE", id_message);
        if (!query->exec()){
            emit workProcessError("Непредвиденная ошибка\nПопробуйте снова позже");
            qDebug() << query->lastError();
            return false;
        }
    }
    return true;
}

void ProjectManager::resetCurrentUserId()
{
    currentUserId = -1;
}

void ProjectManager::addToMessageList(int id, int id_chat)
{
    Q_UNUSED(id_chat);
    QSqlQueryModel* model = new QSqlQueryModel();
    QString que = "select id_message ,id_user, date_message, is_sticker, content_message, last_name, first_name, otch, file_content_ImageScaled  from messages  inner join chat_user as sender on sender.id_chat_user =chat_user_id and sender.id_chat_user in (select id_chat_user from chat_user where user_id not in (select userban_id from banlist where user_id = %1)) inner join users on id_user = sender.user_id left join files on id_file = file_id where id_message = %2";
    model->setQuery(que.arg(currentUserId).arg(id), base);
    QVariantMap item;
    if(model->record(0).value(0).toString() == ""){
        return;
    }
    item.insert("id", model->record(0).value(0).toString());
    item.insert(model->headerData(0, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(0).value(0).toString());
    item.insert(model->headerData(1, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(0).value(1).toString());
    item.insert(model->headerData(2, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(0).value(2).toString().replace('T', ' ').left(16));
    item.insert(model->headerData(3, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(0).value(3).toString());
    item.insert(model->headerData(4, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(0).value(4).toString());
    if (model->record(0).value(7).toString() == "")
        item.insert(model->headerData(5, Qt::Horizontal, Qt::DisplayRole).toString(),  model->record(0).value(5).toString() + " " + model->record(0).value(6).toString().at(0) + ".");
    else
        item.insert(model->headerData(5, Qt::Horizontal, Qt::DisplayRole).toString(),  model->record(0).value(5).toString() + " " + model->record(0).value(6).toString().at(0) + ". " + model->record(0).value(7).toString().at(0) + ".");
    item.insert(model->headerData(8, Qt::Horizontal, Qt::DisplayRole).toString(), model->record(0).value(8));
    messages->addRow(item);
}

void ProjectManager::addNewMessageToConvList(int id_chat)
{
    QSqlQueryModel* model = new QSqlQueryModel();
    query->prepare("select id_chat_user from chat_user where chat_id = :IDCH and user_id = :IDU");
    query->bindValue(":IDCH", id_chat);
    query->bindValue(":IDU", currentUserId);
    if (!query->exec() || !query->first()){
        qDebug() << query->lastError();
        return;
    }
    int id_chat_user = query->value(query->record().indexOf("id_chat_user")).toInt();
    QString que = "select user_id, userfile.file_content_imagescaled as userphoto, content_message, date_message, messages.is_sticker  from chat_user inner join chat on id_chat = chat_id left join messages on id_message in (SELECT MAX(id_message) from messages where chat_user_id in (select id_chat_user from chat_user where chat_id = id_chat and user_id not in (select userban_id from banlist where user_id = %1))) left join users as sender on id_user = (SELECT user_id from chat_user where id_chat_user = chat_user_id) left join files as chatfile on chatfile.id_file = chat.file_id left join files as userfile on userfile.id_file = sender.file_id where id_chat_user = %2 and name_chat like '%' || '%3' || '%' and user_chat_status = true";
    model->setQuery(que.arg(currentUserId).arg(id_chat_user).arg(convSearchFilter), base);
    if(model->record(0).value(0).toString() == ""){
        return;
    }
    convModel->setData(convModel->index(convModel->rowById(id_chat_user), 2), model->record(0).value(0).toString(), Qt::EditRole);
    convModel->setData(convModel->index(convModel->rowById(id_chat_user), 5), model->record(0).value(1), Qt::EditRole);
    if (model->record(0).value(4).toString() == "false")
        convModel->setData(convModel->index(convModel->rowById(id_chat_user), 6), model->record(0).value(2).toString().replace("\n", " "), Qt::EditRole);
    else if (model->record(0).value(4).toString() != "")
        convModel->setData(convModel->index(convModel->rowById(id_chat_user), 6), "Стикер", Qt::EditRole);
    else
        convModel->setData(convModel->index(convModel->rowById(id_chat_user), 6), model->record(0).value(2).toString().replace("\n", " "), Qt::EditRole);
    convModel->setData(convModel->index(convModel->rowById(id_chat_user), 7), model->record(0).value(3).toString().replace('T', ' ').left(16), Qt::EditRole);
    convModel->setData(convModel->index(convModel->rowById(id_chat_user), 9), model->record(0).value(3).toString().replace('T', ' ').left(19), Qt::EditRole);
    proxyConv->sort(9, Qt::DescendingOrder);
}
