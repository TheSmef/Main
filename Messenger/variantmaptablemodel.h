#ifndef VARIANTMAPTABLEMODEL_H
#define VARIANTMAPTABLEMODEL_H

#include <QAbstractTableModel>
#include <QObject>
#include <QtQml/qqml.h>

//абстрактный класс для реализации колонок на его основе и использования принципа инверсии зависимостей в коде C++
class AbstractColumn
{
public:
    //конструктор класса
    //name - название колонки
    AbstractColumn(QString name);
    //метод возвращающий название колонки
    QString name() {return _name;};
    //виртуальный метод абстрактного класса, реализованный внутри класса должен возвращать значение колонки из записи табличного представления
    //rowData - запись из табличного представления, из которой необходимо получить значение
    //role - роль отображения Qt, используеться предустановленный Qt enum
    virtual QVariant colData(const QVariantMap &rowData, int role = Qt::DisplayRole) = 0;
private:
    QString _name;
};

//класс простой колонки
class SimpleColumn : public AbstractColumn
{
public:
    //конструктор класса
    //name - название колонки
    SimpleColumn(QString name);
    //метод класса, который возвращает значение колонки из записи табличного представления
    //rowData - запись из табличного представления, из которой необходимо получить значение
    //role - роль отображения Qt, используеться предустановленный Qt enum
    QVariant colData(const QVariantMap &rowData, int role);
};

//класс реализующий универсальную табличную модель
class VariantMapTableModel : public QAbstractTableModel
{
    Q_OBJECT
    QML_ELEMENT
public:
    //конструктор класса модели
    //parent - родительский объект, используеться для передачи в родительский класс
    VariantMapTableModel(QObject* parent = nullptr);
    //метод регистрирующий новую колонку в модели данных
    //column - экземпляр абстрактного класса (скорее классов реализованного от него), который будет добавлен в модель
    void registerColumn(AbstractColumn* column);
    //метод добавляющий новую запись в модель
    //rowData - данные, которые будет внесены в модель
    void addRow(QVariantMap rowData);
    //метод, добавляющий запись вначало модели сдвигая другие элементы модели на 1 вниз по индексу
    //rowData - данные, которые будет внесены в модель
    void insertRowAtTheBegining(QVariantMap rowData);
    //метод, возвращающий id колонки по индексу записи
    //row - идекс записи в модели
    int idByRow(int row) const;
    //метод, возвращающий индекс колонки по её имени
    //name - название колонки
    int colByName (QString name) const;
    //метод, который возвращает индекс записи в модели по id записи
    //id - функциональное значение, задаваемое при создании записи
    int rowById(int id) const;
    //метод, который возвращает название колонки по её индексу
    //col - индекс колонки
    QString nameByCol(int col) const;
    //метод, возвращающий количество записей в модели
    //parent - параметр из абстрактного класса, экзепляр индекса модели
    int rowCount(const QModelIndex &parent) const override;
    //метод, который возвращает количество колонок в модели
    //parent - параметр из абстрактного класса, экзепляр индекса модели
    int columnCount(const QModelIndex &parent) const override;
    //метод, который возвращает значение колонки, используеться представлениями
    //index - индекс колонки и записи, по которому необходимо вернуть значение
    //role - роль отображения Qt, используеться предустановленный Qt enum
    QVariant data(const QModelIndex &index, int role) const override;
    //метод, который устанавливает новые данные в уже существующую запись
    //index - индекс колонки и записи, по которым необходимо поменять значение
    //value - значение, которое необходимо установить
    //role - роль отображения Qt, используеться предустановленный Qt enum
    bool setData(const QModelIndex &index, const QVariant &value, int role) override;
    //метод, используемый для связки с Qml, используеться для сигнализирования для Qml наличия флагов
    //index - индекс колонки и записи, для которых запращиваются флаги
    Qt::ItemFlags flags(const QModelIndex &index) const override;
    //метод, используемый для связки с Qml, возвращает для Qml роли модели, посредством которых идёт обращение к модели
    Q_INVOKABLE QHash<int, QByteArray> roleNames() const;
    //метод, удаляющий запись в модели
    //row - индекс колонки, которую необходимо удалить
    //parent - параметр из абстрактного класса, экзепляр индекса модели
    bool removeRow(int row, const QModelIndex &parent);
private:
    QList<int> _rowIndex;
    QHash<int, QVariantMap> _dataHash;
    QList<AbstractColumn*> _columns;
};

#endif // VARIANTMAPTABLEMODEL_H
