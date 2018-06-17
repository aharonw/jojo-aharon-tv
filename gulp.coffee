gulp     = require 'gulp'
debug    = require 'gulp-debug'
rename   = require "gulp-rename"

stylus   = require 'gulp-stylus'
nib      = require 'nib'
jeet     = require 'jeet'
rupture  = require 'rupture'
concat   = require 'gulp-concat-css'
minify   = require 'gulp-minify-css'

pug      = require 'gulp-pug'
layout   = require 'gulp-layout'

fs       = require 'fs'
gutil    = require 'gulp-util'
front    = require 'gulp-front-matter'
toJSON   = require 'gulp-markdown-to-json'
data     = require 'gulp-data'

_        = require 'underscore'

marked   = require 'marked'
markdown = require 'gulp-markdown'

config   = require './config.coffee'
s3       = require('gulp-s3-upload')(config.s3)
src      = config.source


allIndexs = (file) ->
  slug = file.basename
  console.log slug
  if slug is 'index'
    file.dirname = ''
  else
    if file.basename in ['wedding-day', 'bridgeton', 'lodging', 'travel', 'faqs']
      file.dirname = file.basename
    else
      file.dirname = slug.split("-").slice(2,slug.length).join('-')
  file.basename = 'index'


# Complie HTML
gulp.task 'templates', ->

  gulp.src src.templates
    .pipe debug {title: 'unicorn:'}
    .pipe pug()
    .pipe rename allIndexs
    .pipe gulp.dest './build'


# Build progress css
gulp.task 'css', ->
  gulp.src src.stylus
    .pipe debug {title: 'unicorn:'}
    .pipe stylus
      use: [ nib(), jeet(), rupture() ]
      compress: true
    .pipe concat 'styles.css'
    .pipe minify({compatibility: 'ie8'})
    .pipe gulp.dest './build/styles'


# Copy assets to build directory
gulp.task 'assets', ->
  gulp.src src.assets
    .pipe gulp.dest './build'


# Deploy to S3
gulp.task 'deploy', ->
  gulp.src './build/**/'
    .pipe debug {title: 'unicorn:'}
    .pipe s3 { Bucket: 'jojo.aharon.tv', ACL: 'public-read' }


gulp.task 'default', ->
  gulp.watch src.templates, ['templates']
  gulp.watch src.stylus, ['css']
  gulp.watch src.assets, ['assets']
