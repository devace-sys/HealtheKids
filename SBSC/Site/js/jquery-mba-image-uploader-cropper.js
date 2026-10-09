; var MBA = MBA || {};

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.ImageUploaderCommon
 * @memberof     MBA
 * @summary      Static methods for advanced image uploading with cropping and security features
 * @description  Modern image upload component with enhanced cropping functionality and comprehensive security validation
 * @requires     jQuery, HTML5 Canvas API
 */

MBA.ImageUploaderCommon = (function ($) {
    'use strict';

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _PLUGIN_NAME = 'MBA Image Uploader';

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnCreateImageCropper
     * @private
     * @summary      Creates Instagram-style image cropper with drag-to-position and grid overlay
     * @param  {File}    file  The image file to crop
     * @param  {Object}  opts  Options object
     * @return {Promise}       Promise resolving to cropped image blob
     */
    const _fnCreateImageCropper = function (file, opts) {
        return new Promise((resolve, reject) => {
            const cropperSettings = opts.cropperSettings;
            let isDragging = false;
            let dragStart = { x: 0, y: 0 };
            let imagePosition = { x: 0, y: 0 };
            let imageScale = 1;

            // Create Instagram-style cropper modal HTML
            const cropperHtml = `
                <div class="${opts.cssClasses.cropperModal}">
                    <div class="${opts.cssClasses.cropperContainer}">
                        <div class="mba-image-uploader-cropper-header">
                            <h4 class="text-dark mb-0">
                                <i class="fa fa-crop me-2"></i>Crop Your Image
                            </h4>
                            <p class="text-muted small mb-3">Drag to reposition your image</p>
                        </div>
                        
                        <div class="${opts.cssClasses.cropperCanvas}" id="cropperCanvas">
                            <canvas class="mba-image-uploader-main-canvas"></canvas>
                            ${cropperSettings.showGrid
                    ? `
                                <div class="${opts.cssClasses.cropperGrid}">
                                    <div class="mba-image-uploader-grid-line mba-image-uploader-grid-vertical" style="left: 33.33%"></div>
                                    <div class="mba-image-uploader-grid-line mba-image-uploader-grid-vertical" style="left: 66.66%"></div>
                                    <div class="mba-image-uploader-grid-line mba-image-uploader-grid-horizontal" style="top: 33.33%"></div>
                                    <div class="mba-image-uploader-grid-line mba-image-uploader-grid-horizontal" style="top: 66.66%"></div>
                                </div>
                            `
                    : ''
                }
                            <div class="${opts.cssClasses.cropperCircle}"></div>
                        </div>
                        
                        <div class="${opts.cssClasses.cropperPreview}">
                            <div class="mba-image-uploader-preview-label">Preview</div>
                            <div class="mba-image-uploader-preview-circle">
                                <canvas class="mba-image-uploader-preview-canvas"></canvas>
                            </div>
                        </div>
                        
                        <div class="${opts.cssClasses.cropperControls}">
                            <div class="d-flex gap-2 justify-content-center">
                                <button type="button" class="${opts.cssClasses.cropperBtn} btn btn-outline-secondary mba-image-uploader-crop-cancel">
                                    <i class="fa fa-times me-1"></i>Cancel
                                </button>
                                <button type="button" class="${opts.cssClasses.cropperBtn} btn btn-primary mba-image-uploader-crop-save">
                                    <i class="fa fa-check me-1"></i>Save
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            `;

            // Add to body
            $('body').append(cropperHtml);

            const $modal = $('.' + opts.cssClasses.cropperModal);
            const $canvas = $('.mba-image-uploader-main-canvas')[0];
            const $previewCanvas = $('.mba-image-uploader-preview-canvas')[0];
            const ctx = $canvas.getContext('2d');
            const previewCtx = $previewCanvas.getContext('2d');

            // Set canvas dimensions
            const canvasSize = cropperSettings.cropSize;
            $canvas.width = canvasSize;
            $canvas.height = canvasSize;
            $previewCanvas.width = 120;
            $previewCanvas.height = 120;

            // Load and display image
            const img = new Image();
            img.onload = function () {
                // Calculate initial scale to fill the circular crop area (Instagram style)
                const minScale = Math.max(canvasSize / img.width, canvasSize / img.height);
                imageScale = minScale;

                // Center the image
                imagePosition = {
                    x: (canvasSize - img.width * imageScale) / 2
                    , y: (canvasSize - img.height * imageScale) / 2
                };

                // Initial draw
                _fnDrawImage();
                _fnUpdatePreview();
            };

            img.src = URL.createObjectURL(file);

            // Drawing function
            function _fnDrawImage() {
                ctx.clearRect(0, 0, canvasSize, canvasSize);
                ctx.save();

                // Draw image with current position and scale
                ctx.drawImage(
                    img
                    , imagePosition.x
                    , imagePosition.y
                    , img.width * imageScale
                    , img.height * imageScale
                );
                ctx.restore();
            }

            // Preview update function
            function _fnUpdatePreview() {
                previewCtx.clearRect(0, 0, 120, 120);
                previewCtx.save();

                // Create circular clipping path for preview
                previewCtx.beginPath();
                previewCtx.arc(60, 60, 60, 0, 2 * Math.PI);
                previewCtx.clip();

                // Draw scaled version of main canvas
                const scale = 120 / canvasSize;
                previewCtx.scale(scale, scale);
                previewCtx.drawImage($canvas, 0, 0);

                previewCtx.restore();
            }

            // Mouse/touch events for dragging (Instagram-style)
            $($canvas).on('mousedown touchstart', function (e) {
                isDragging = true;
                const clientX =
                    e.originalEvent.clientX || e.originalEvent.touches[0].clientX;
                const clientY =
                    e.originalEvent.clientY || e.originalEvent.touches[0].clientY;
                const rect = $canvas.getBoundingClientRect();

                dragStart = {
                    x: clientX - rect.left - imagePosition.x
                    , y: clientY - rect.top - imagePosition.y
                };

                // Change cursor to grabbing
                $($canvas).css('cursor', 'grabbing');
                e.preventDefault();
            });

            $(document).on('mousemove touchmove', function (e) {
                if (!isDragging) return;

                const clientX =
                    e.originalEvent.clientX || e.originalEvent.touches[0].clientX;
                const clientY =
                    e.originalEvent.clientY || e.originalEvent.touches[0].clientY;
                const rect = $canvas.getBoundingClientRect();

                imagePosition = {
                    x: clientX - rect.left - dragStart.x
                    , y: clientY - rect.top - dragStart.y
                };

                _fnDrawImage();
                _fnUpdatePreview();
                e.preventDefault();
            });

            $(document).on('mouseup touchend', function () {
                if (isDragging) {
                    isDragging = false;
                    $($canvas).css('cursor', 'grab');
                }
            });

            // Cancel button
            $('.mba-image-uploader-crop-cancel').on('click', function () {
                $modal.fadeOut(300, function () {
                    $(this).remove();
                    $(document).off('mousemove touchmove mouseup touchend');
                });
                opts.fnOnCropCancel();
                reject(new Error('Cropping cancelled'));
            });

            $('.mba-image-uploader-crop-save').on('click', function () {
                // Create final cropped canvas
                const outputCanvas = document.createElement('canvas');
                const outputCtx = outputCanvas.getContext('2d');
                const outputSize = 300; // Final output size

                outputCanvas.width = outputSize;
                outputCanvas.height = outputSize;

                // Create circular clipping path
                outputCtx.beginPath();
                outputCtx.arc(
                    outputSize / 2
                    , outputSize / 2
                    , outputSize / 2
                    , 0
                    , 2 * Math.PI
                );
                outputCtx.clip();

                // Scale and draw the cropped image
                const scale = outputSize / canvasSize;
                outputCtx.scale(scale, scale);
                outputCtx.drawImage($canvas, 0, 0);

                // Convert to blob
                outputCanvas.toBlob(
                    function (blob) {
                        $modal.fadeOut(300, function () {
                            $(this).remove();
                            $(document).off('mousemove touchmove mouseup touchend');
                        });
                        resolve(blob);
                    }
                    , cropperSettings.outputFormat
                    , cropperSettings.outputQuality
                );
            });

            // Show modal with animation
            $modal.hide().fadeIn(300);
        });
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    return {
        PLUGIN_NAME: _PLUGIN_NAME
        , fnCreateImageCropper: _fnCreateImageCropper
    };
})(jQuery);