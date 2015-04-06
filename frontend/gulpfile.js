/*!
 * gulp
 * $ npm install gulp-ruby-sass gulp-autoprefixer gulp-minify-css gulp-jshint gulp-concat gulp-uglify gulp-imagemin gulp-notify gulp-rename gulp-livereload gulp-cache del --save-dev
 */

// Load plugins
var gulp = require('gulp'),
    sass = require('gulp-ruby-sass'),
    autoprefixer = require('gulp-autoprefixer'),
    minifycss = require('gulp-minify-css'),
    imagemin = require('gulp-imagemin'),
    jshint = require('gulp-jshint'),
    rename = require('gulp-rename'),
    concat = require('gulp-concat'),
    notify = require('gulp-notify'),
    cache = require('gulp-cache'),
    livereload = require('gulp-livereload'),
    del = require('del'),
    coffee = require('gulp-coffee'),
    sourcemaps = require('gulp-sourcemaps'),
    coffeelint = require('gulp-coffeelint'),
    serve = require('gulp-serve')

var imageFiles = ['./public/**/*.{png,jpg,gif}'];
var staticFiles = ['./public/**/*.{html,css,mp3,ogg}'];
var dest = './public-dist';

// Static Files
gulp.task('statics', function() {
   gulp.src(staticFiles)
   .pipe(gulp.dest(dest));
});

gulp.task('dependencies', function() {
   gulp.src('./bower_components/**/*', {base: '.'})
   .pipe(gulp.dest(dest));
});

// Styles
gulp.task('styles', function() {
  sass('public', { style: 'expanded' }).pipe(gulp.dest(dest))
});

// Scripts
gulp.task('scripts', function() {
  return gulp.src(['./public/**/*.js'], {base: 'public'})
    .pipe(jshint('.jshintrc'))
    .pipe(jshint.reporter('default'))
    .pipe(gulp.dest(dest))
    .pipe(notify({ message: 'Scripts task complete' }));
});

gulp.task('compile-coffee', function() {
  return gulp.src(['./public/**/*.coffee'], { base: 'public' })
    .pipe(coffeelint())
    .pipe(coffeelint.reporter())
    .pipe(sourcemaps.init())
    .pipe(coffee())
    .pipe(sourcemaps.write())
    .pipe(gulp.dest(dest));
});

// Images
gulp.task('images', function() {
  return gulp.src(imageFiles, { base: 'public' })
    .pipe(imagemin({ optimizationLevel: 3, progressive: true, interlaced: true }))
    .pipe(gulp.dest(dest));
});

// Clean
gulp.task('clean', function(cb) {
    del([dest], {force:true}, cb)
});

// Watch
gulp.task('watch', function() {

  // Watch .scss files
  gulp.watch(['./public/**/*.scss'], ['styles']);

  // Watch .js files
  gulp.watch(['./public/**/*.js'], ['scripts']);

  // Watch .coffee files
  gulp.watch(['./public/**/*.coffee'], ['compile-coffee']);

  // Watch image files
  gulp.watch(imageFiles, ['images']);

  // Watch static files
  gulp.watch(staticFiles, ['statics']);
});

// Serve
gulp.task('serve', serve({root:dest, port: 8000}));

// Default task
gulp.task('default', function() {
    gulp.start('statics', 'dependencies', 'styles', 'compile-coffee', 'scripts', 'images', 'serve', 'watch');
});

