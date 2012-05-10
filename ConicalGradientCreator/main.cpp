/**
 *  (c) 2012 Thomas Moenicke
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#include <QCoreApplication>

#include <QImage>
#include <QPainter>

struct GradientSettings
{
    QColor background;
    QColor color_1;
    QColor color_2;

     QSize size;
     qreal angle;
   QString output;
};

class GradientFactory {

    GradientFactory() {}

public:

    static void generateConicalGradient(const GradientSettings& settings)
    {
        QImage paintDevice(settings.size, QImage::Format_ARGB32);
        QPainter painter(&paintDevice);
        painter.setRenderHint(QPainter::Antialiasing);

        painter.fillRect(paintDevice.rect(),settings.background);

        const QRect ellipseRect = paintDevice.rect().adjusted(30,30,-30,-30);

        QConicalGradient conical( ellipseRect.center(), settings.angle );
        conical.setColorAt( 0.0, settings.color_1);
        conical.setColorAt(0.25, settings.color_2);
        conical.setColorAt( 0.5, settings.color_1);
        conical.setColorAt(0.75, settings.color_2);
        conical.setColorAt( 1.0, settings.color_1);

        painter.setBrush( conical );
        painter.setPen(Qt::transparent);

        painter.drawEllipse(ellipseRect);

        if (!paintDevice.save(settings.output,"PNG"))
            qCritical("could not save image file.");
    }
};

int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);

    GradientSettings settings;
    settings.background = Qt::transparent;
    settings.color_1 = QColor(100,100,100);
    settings.color_2 = QColor(255,255,255);

    settings.size = QSize(600,600);
    settings.angle = -45.0f;

    settings.output = "/home/thomas/conicalGradient.png";

    GradientFactory::generateConicalGradient(settings);
}
