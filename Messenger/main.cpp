#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "settingsfilemanager.h"
#include "projectmanager.h"


int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    qmlRegisterType<VariantMapTableModel>("io.varianttablemodel", 1, 0, "VariantTableModel");
    qmlRegisterType<QSortFilterProxyModel>("io.QSortFilterProxyModel", 1, 0, "QSortFilterProxyModel");
    SettingsFileManager* settings =  new SettingsFileManager();
    engine.rootContext()->setContextProperty("Settings", settings);
    ProjectManager* manager = new ProjectManager();
    engine.rootContext()->setContextProperty("manager", manager);
    engine.load(url);
    return app.exec();
}
