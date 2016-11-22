var gulp = require('gulp'),
    settings  = require('./settings.json'),
    project   = require('./package.json'),
    include   = require('gulp-include'),
    minifyJS  = require('gulp-minify'),
    stylus    = require('gulp-stylus'),
    prefixer  = require('gulp-autoprefixer'),
    jade      = require('gulp-jade'),
    coffee    = require('gulp-coffee'),
    gulpif    = require('gulp-if'),
    rename    = require('gulp-rename');

var PATH_TO_STYLES  = 'src/css/',
    PATH_TO_SCRIPTS = 'src/js/',
    PATH_TO_JADE    = 'src/tpl/',
    PATH_TO_BLOCKS  = 'src/tpl/blocks/*.jade',
    PATH_TO_TMP     = 'src/.tmp/';

gulp.task('default', ['tpl'], function() {
    gulp.watch('src/**/*.*', ['tpl']);
});

gulp.task('styles', function() {
    // return is important here
    return gulp.src(PATH_TO_STYLES + 'index.styl')
        .pipe(stylus({
            'include css': true,
            'compress'   : !settings.debug,
            'rawDefine': {
                'inline-image': stylus.stylus.url()
            }
        }))
        .pipe(prefixer(['> 0%']))
        .pipe(rename('styles.css'))
        .pipe(gulp.dest(PATH_TO_TMP));
});

gulp.task('scripts', function() {
    // return is important here
    return gulp.src(PATH_TO_SCRIPTS + 'index.coffee')
        .pipe(include())
        .pipe(coffee({bare: true}).on('error', console.log))
        .pipe(gulpif(!settings.debug, minifyJS({ compress: true, noSource: true })))
        .pipe(rename('scripts.js'))
        .pipe(gulp.dest(PATH_TO_TMP));
});

gulp.task('blocks', function() {
    return gulp.src(PATH_TO_BLOCKS)
        .pipe(jade({
            pretty: false,
            locals: {
                settings: settings
            }
        }))
        .pipe(rename({extname:'.html'}))
        .pipe(gulp.dest(PATH_TO_TMP));    
});

gulp.task('tpl', ['styles', 'scripts'], function() {
    return gulp.src(PATH_TO_JADE + 'index.jade')
        .pipe(jade({
            pretty: '    ',
            locals: {
                settings: settings
            }
        }))
        .pipe(rename('happy-hours.html'))
        .pipe(gulp.dest('../../jail/site/misc/ru/files'));   
});