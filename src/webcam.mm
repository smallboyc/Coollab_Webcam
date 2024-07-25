
#include <iostream>
#include <AVFoundation/AVFoundation.h>
#include <CoreMedia/CMFormatDescription.h>
#include "webcam.hpp"

namespace webcam {

//Webcams infos
std::vector<Info> getWebcamsInfo() {
    std::vector<Info> webcams;
    
    // Add all possible device types to ensure external cameras are included
    AVCaptureDeviceDiscoverySession* session = 
        [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[
            AVCaptureDeviceTypeBuiltInWideAngleCamera, 
            AVCaptureDeviceTypeExternal
        ]
        mediaType:AVMediaTypeVideo
        position:AVCaptureDevicePositionUnspecified];

    // Get the list of devices
    NSArray<AVCaptureDevice*>* devices = [session devices];
    for (AVCaptureDevice* device in devices) {
        Info webcamInfo;
        webcamInfo.name = [device.localizedName UTF8String];
        webcamInfo.unique_id = UniqueId([device.uniqueID UTF8String]);

        // Query available resolutions
        for (AVCaptureDeviceFormat* format in device.formats) {
            CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription);
            Resolution resolution{ dimensions.width, dimensions.height };
            if (std::find(webcamInfo.available_resolutions.begin(), webcamInfo.available_resolutions.end(), resolution) == webcamInfo.available_resolutions.end()) {
                webcamInfo.available_resolutions.push_back(resolution);
            }
            // Query available pixel formats
            FourCharCode pixelFormat = CMFormatDescriptionGetMediaSubType(format.formatDescription);
            char formatString[5] = {0};
            *(UInt32 *)formatString = CFSwapInt32HostToBig(pixelFormat);
            webcamInfo.pixel_formats.push_back(std::string(formatString));
        }

        webcams.push_back(webcamInfo);
    }
    return webcams;
}










void Capture::thread_job(Capture &This) {
    @autoreleasepool {
        // Récupère le périphérique de capture en fonction de l'ID unique
        AVCaptureDevice* device = [AVCaptureDevice deviceWithUniqueID:[NSString stringWithUTF8String:This._unique_id.getDevicePath().c_str()]];
        if (!device) {
            std::cerr << "Error: Could not find device" << std::endl;
            This._has_stopped = true;
            return;
        }

        // Crée l'entrée de périphérique pour la capture vidéo
        NSError* error = nil;
        AVCaptureDeviceInput* input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        if (!input) {
            std::cerr << "Error: Could not create input device: " << [[error localizedDescription] UTF8String] << std::endl;
            This._has_stopped = true;
            return;
        }

        // Initialise une session de capture
        AVCaptureSession* session = [[AVCaptureSession alloc] init];
        [session beginConfiguration];

        // Ajoute l'entrée au session si possible
        if ([session canAddInput:input]) {
            [session addInput:input];
        }

        // Configure la sortie vidéo
        AVCaptureVideoDataOutput* output = [[AVCaptureVideoDataOutput alloc] init];
        output.videoSettings = @{
            (NSString*)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)
        };

    //     // Crée une file d'attente pour la gestion des échantillons vidéo
    //     dispatch_queue_t queue = dispatch_queue_create("videoQueue", NULL);
    //     auto selfCapture = this; 
    //     [output setSampleBufferDelegate:(id<AVCaptureVideoDataOutputSampleBufferDelegate>)selfCapture queue:queue];

    //     // Ajoute la sortie à la session si possible
    //     if ([session canAddOutput:output]) {
    //         [session addOutput:output];
    //     }

    //     // Finalise la configuration de la session et démarre la capture
    //     [session commitConfiguration];
    //     [session startRunning];

    //     // Boucle principale de capture vidéo, s'arrête lorsque _wants_to_stop_thread devient vrai
    //     while (!This._wants_to_stop_thread) {
    //         std::this_thread::sleep_for(std::chrono::milliseconds(30)); // Capture une image toutes les 30ms
            
    //     }

    //     // Arrête la session de capture lorsque la boucle se termine
    //     [session stopRunning];
    // }
    // // Indique que la capture s'est arrêtée
    // This._has_stopped = true;
}
}
void Capture::stop_capture() {
    _wants_to_stop_thread = true;
}

// void Capture::captureOutput(AVCaptureOutput* output, CMSampleBufferRef buffer, AVCaptureConnection* connection) {
//     @autoreleasepool {
//         // Obtient le tampon d'image à partir de l'échantillon de tampon
//         CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(buffer);
//         CVPixelBufferLockBaseAddress(imageBuffer, 0);

//         // Récupère les informations sur l'image (largeur, hauteur, bytes per row)
//         uint8_t* baseAddress = (uint8_t*)CVPixelBufferGetBaseAddress(imageBuffer);
//         size_t width = CVPixelBufferGetWidth(imageBuffer);
//         size_t height = CVPixelBufferGetHeight(imageBuffer);
//         size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);

//         // Copie les données de l'image dans un tableau unique_ptr<uint8_t[]>
//         size_t dataSize = height * bytesPerRow;
//         auto data = std::make_unique<uint8_t[]>(dataSize);
//         memcpy(data.get(), baseAddress, dataSize);

//         CVPixelBufferUnlockBaseAddress(imageBuffer, 0);

//         // Verrouille le mutex pour mettre à jour l'image disponible
//         {
//             std::lock_guard<std::mutex> lock(_mutex);
//             _available_image = img::Image({static_cast<uint32_t>(width), static_cast<uint32_t>(height)}, 4, data.release());
//         }
//     }

} // namespace webcam
