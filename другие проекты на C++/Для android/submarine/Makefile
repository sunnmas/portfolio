TARGET = submarine
CC = g++
LDFLAGS = -I/usr/local/include -L/opt/vc/lib -L/usr/local/lib -lraspicam -lmmal -lmmal_core -lmmal_util -ljpeg
LDFLAGS += -D_REENTERANT -I/usr/include/nptl -L/usr/lib/nptl -lpthread

all: $(TARGET)

$(TARGET): gamepad.o telemetry.o camera.o transmit.o 
	$(CC) gamepad.o telemetry.o camera.o transmit.o main.cpp -o $(TARGET) $(LDFLAGS)

gamepad.o: ./cpp/gamepad.cpp
	$(CC) -c ./cpp/gamepad.cpp

telemetry.o: ./cpp/telemetry.cpp
	$(CC) -c ./cpp/telemetry.cpp

camera.o: ./cpp/camera.cpp
	$(CC) -c ./cpp/camera.cpp $(LDFLAGS)

transmit.o: ./cpp/transmit.cpp
	$(CC) -c ./cpp/transmit.cpp

clean:
	rm -f *.o submarine
