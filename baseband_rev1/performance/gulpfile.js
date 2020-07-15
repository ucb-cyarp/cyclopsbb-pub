//Based on https://code.visualstudio.com/docs/languages/markdown
//https://www.npmjs.com/package/gulp-markdown-it
//https://github.com/markdown-it/markdown-it#usage-examples
//https://gulpjs.com/docs/en/getting-started/quick-start/
//https://stackoverflow.com/questions/34842771/copying-files-with-gulp
//https://medium.com/@dave_lunny/task-dependencies-in-gulp-b885c1ab48f0
//liquidlight.co.uk/blog/how-do-i-update-to-gulp-4/
//https://stackoverflow.com/questions/38374936/how-can-i-use-gulp-to-add-a-line-of-text-to-a-file

const gulp = require('gulp');
const markdown = require('gulp-markdown-it');
var replace = require('gulp-replace');
var header = require('gulp-header');
var footer = require('gulp-footer');
 
gulp.task('copy-img', function() {
    return gulp.src('*.png')
      .pipe(gulp.dest('build'));
  });

gulp.task('copy-css', function() {
    return gulp.src('assets/*.css')
      .pipe(gulp.dest('build'));
  });

gulp.task('convert-md', function() {
    return gulp.src('*.md')
        .pipe(markdown())
        .pipe(gulp.dest('build'));
  });

gulp.task('replace-md-Links', gulp.series('convert-md', function() {
    return gulp.src(['build/*.html'])
      .pipe(replace('.md', '.html'))
      .pipe(gulp.dest('build/'));
  }));

gulp.task('insert-html-header', gulp.series('replace-md-Links', function() {
return gulp.src(['build/*.html'])
    .pipe(header('<html>\n<head>\n<link rel="stylesheet" type="text/css" href="skeleton.css">\n</head>\n<body>'))
    .pipe(gulp.dest('build/'));
}));

gulp.task('insert-html-footer', gulp.series('insert-html-header', function() {
    return gulp.src(['build/*.html'])
        .pipe(footer('</body>\n</html>'))
        .pipe(gulp.dest('build/'));
    }));

gulp.task('default', gulp.series('insert-html-footer','copy-img','copy-css'));