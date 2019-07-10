/*
 *= require slick
 */

$(document).ready(function () {
    var object_width = $('.slide').width();


    var slides_to_show = function () {
        var slider = $('.slider');
        var slider_nav = $('.slider-nav');

        if (slider_nav.length) {
            return Math.floor(slider_nav.width() / slider_nav.find('img')[0].width);
        } else if (slider.length) {
            var slider_width = slider.width();
            var slides = Math.floor(slider_width / object_width);
            return slides > 0 ? slides : 1;
        }
        return 3;
    };


    var slides = slides_to_show();

    $('.slider').slick({
        arrows: false,
        autoplay: true,
        dots: true,
        lazyLoad: 'ondemand',
        slidesToShow: slides,
        slidesToScroll: slides,
        responsive: [
            {
                breakpoint: 1200,
                settings: {
                    slidesToShow: 2,
                    slidesToScroll: 2
                }
            },

            {
                breakpoint: 768,
                settings: {
                    slidesToShow: 1,
                    slidesToScroll: 1
                }
            }
        ]
    });

    $('.slider-content').slick({
        slidesToShow: 1,
        slidesToScroll: 1,
        arrows: false,
        asNavFor: '.slider-nav'
    });

    $('.slider-nav').slick({
        slidesToShow: slides,
        slidesToScroll: 1,
        asNavFor: '.slider-content',
        focusOnSelect: true
    });

    $('.banner-slider').slick({
        slidesToShow: 1,
        slidesToScroll: 1,
        arrows: true,
        dots: true,
        autoplay: true
    });

    window.onresize = function (event) {
        var slides = slides_to_show();
        $('.slider-nav').slick('slickSetOption', 'slidesToShow', slides, true);
        $('.slider-content').slick('slickSetOption', 'slidesToShow', slides, true);
        $('.slider').slick('slickSetOption', 'slidesToScroll', slides, true);
        $('.banner-slider').slick('slickSetOption', 'slidesToScroll', 1, true);
    };
});
