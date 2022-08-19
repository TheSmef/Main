#include "variantmaptablemodel.h"



VariantMapTableModel::VariantMapTableModel(QObject* parent)
    :QAbstractTableModel(parent)
{

}

void VariantMapTableModel::registerColumn(AbstractColumn *column)
{
    _columns.append(column);
}

void VariantMapTableModel::addRow(QVariantMap rowData)
{
    int id = rowData.value("id").toInt();
    if (_rowIndex.contains(id)){
        return;
    }
    beginInsertRows(QModelIndex(), _rowIndex.count(), _rowIndex.count());
    _rowIndex.append(id);
    _dataHash.insert(id, rowData);
    endInsertRows();
}

void VariantMapTableModel::insertRowAtTheBegining(QVariantMap rowData)
{
    int id = rowData.value("id").toInt();
    beginInsertRows(QModelIndex(), 0, 0);
    _rowIndex.insert(0, id);
    _dataHash.insert(id, rowData);
    endInsertRows();
}

int VariantMapTableModel::idByRow(int row) const
{
    return _rowIndex.at(row);
}

int VariantMapTableModel::colByName(QString name) const
{
    for (int col = 0; col < _columns.count(); col++)
    {
        if (nameByCol(col) == name)
        {
            return col;
        }
    }
    return -1;
}

int VariantMapTableModel::rowById(int id) const
{
    return _rowIndex.indexOf(id);
}

QString VariantMapTableModel::nameByCol(int col) const
{
    return _columns.at(col)->name();
}

int VariantMapTableModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return _rowIndex.count();
}

int VariantMapTableModel::columnCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return _columns.count();
}

QVariant VariantMapTableModel::data(const QModelIndex &index, int role) const
{
if (!index.isValid())
{
    return QVariant();
}
if (role >= Qt::UserRole)
{
    return data(this->index(index.row(), role - Qt::UserRole), Qt::DisplayRole);
}
int id = idByRow(index.row());
QVariantMap rowData = _dataHash.value(id);
return _columns.at(index.column())->colData(rowData, role);
}

bool VariantMapTableModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (!index.isValid())
    {
        return false;
    }
    if (role == Qt::EditRole)
    {
        int id = idByRow(index.row());
        _dataHash[id].insert(nameByCol(index.column()), value);
        emit dataChanged(index, index);
        return true;
    }
    return false;
}

bool VariantMapTableModel::removeRow(int row, const QModelIndex &parent)
{
    if (row == -1){
        return false;
    }
    if (!_rowIndex.contains(idByRow(row))){
        return false;
    }
    beginRemoveRows(parent, row, row);
    _dataHash.remove(idByRow(row));
    _rowIndex.removeAt(row);
    endRemoveRows();
    return true;
}

Qt::ItemFlags VariantMapTableModel::flags(const QModelIndex &index) const
{
    if (!index.isValid())
    {
        return Qt::NoItemFlags;
    }
    return Qt::ItemIsEnabled | Qt::ItemIsSelectable | Qt::ItemIsEditable;
}



QHash<int, QByteArray> VariantMapTableModel::roleNames() const
{
    QHash<int, QByteArray> roles = QAbstractTableModel::roleNames();
    for(int col=0; col<_columns.count(); col++)
    {
        roles.insert(Qt::UserRole + col, _columns.at(col)->name().toUtf8());
    }
    qDebug() << roles;
    return roles;
}



AbstractColumn::AbstractColumn(QString name) : _name(name)
{

}

SimpleColumn::SimpleColumn(QString name) : AbstractColumn(name)
{

}

QVariant SimpleColumn::colData(const QVariantMap &rowData, int role)
{
    if (role != Qt::DisplayRole && role != Qt::EditRole)
    {
        return QVariant();
    }
    return rowData.value(name());
}

