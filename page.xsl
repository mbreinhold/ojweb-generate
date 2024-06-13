<?xml version="1.0" encoding="utf-8"?>

<!--
  Copyright (c) 2021, Oracle and/or its affiliates. All rights reserved.
  DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.

  This code is free software; you can redistribute it and/or modify it
  under the terms of the GNU General Public License version 2 only, as
  published by the Free Software Foundation.  Oracle designates this
  particular file as subject to the "Classpath" exception as provided
  by Oracle in the LICENSE file that accompanied this code.

  This code is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
  version 2 for more details (a copy is included in the LICENSE file that
  accompanied this code).

  You should have received a copy of the GNU General Public License version
  2 along with this work; if not, write to the Free Software Foundation,
  Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA.

  Please contact Oracle, 500 Oracle Parkway, Redwood Shores, CA 94065 USA
  or visit www.oracle.com if you need additional information or have any
  questions.
  -->

<!DOCTYPE s:stylesheet [
  <!ENTITY nl "&#x0a;">
  <!ENTITY copy "&#xa9;">
  <!ENTITY dot "&#xb7;">
  <!ENTITY quad "&#x2001;">
  <!ENTITY qquad "&quad;&quad;">
]>

<s:stylesheet xmlns:s="http://www.w3.org/1999/XSL/Transform"
              xmlns:h="http://www.w3.org/1999/xhtml"
              xmlns="http://www.w3.org/1999/xhtml"
              version="1.0"
              exclude-result-prefixes="h">

<s:output method="html"
  indent="no"
  encoding="utf-8"
  doctype-system="html"/>

<s:template match="@*|node()">
  <s:copy>
    <s:apply-templates select="@*|node()"/>
  </s:copy>
</s:template>

<!-- Serried H4 headers -->

<s:template match="h:section/*[1][name()='h4' and following-sibling::*[1][name()='p']]">
  <p class="br">
    <b>
      <a class="anchor">
        <s:attribute name="href">
          <s:text>#</s:text>
          <s:value-of select="../@id"/>
        </s:attribute>
        <s:copy-of select="*|text()"/>
      </a>
    </b>
    <s:text>&qquad;</s:text>
    <s:copy-of select="following-sibling::*[1][name()='p']/node()"/>
  </p>
</s:template>

<s:template match="h:p[preceding-sibling::*[1][name()='h4']]"/>

<!-- Header anchors -->

<s:template match="h:section/h:h2|h:section/h:h3
                   |h:section/h:h4[not(following-sibling::*[1][name()='p'])]">
  <s:copy>
    <a class="anchor">
      <s:attribute name="href">
        <s:text>#</s:text>
        <s:value-of select="../@id"/>
      </s:attribute>
      <s:apply-templates select="@*|node()"/>
    </a>
  </s:copy>
</s:template>

<!-- Table of contents -->

<s:template mode="toc" match="@*|node()">
  <s:param name="div-id" select="none"/>
  <s:copy>
    <s:apply-templates mode="toc" select="@*|node()">
      <s:with-param name="div-id" select="$div-id"/>
    </s:apply-templates>
  </s:copy>
</s:template>

<s:template mode="toc" match="h:li">
  <s:param name="div-id" select="none"/>
  <s:variable name="id" select="substring(h:a/@href, 2)"/>
  <s:if test="not(//h:section[@id=$id]
                  /ancestor-or-self::h:section/@data-toc='omit') and
              not(//h:section[@id=$id]
                  /ancestor::h:section[@data-toc='omit-children']) and
              not($id=$div-id)">
    <s:copy>
      <s:apply-templates mode="toc" select="*">
        <s:with-param name="div-id" select="$div-id"/>
      </s:apply-templates>
    </s:copy>
  </s:if>
</s:template>

<s:template mode="toc" match="h:nav[@id='TOC']">
  <s:param name="div-id" select="none"/>
  <s:text>&nl;</s:text>
  <nav class="toc">
    <s:apply-templates mode="toc" select="h:ul/h:li/h:ul">
      <s:with-param name="div-id" select="$div-id"/>
    </s:apply-templates>
  </nav>
</s:template>

<s:template match="h:div[@class='table-of-contents']">
  <s:apply-templates mode="toc" select="//h:nav[@id='TOC']">
    <!-- Pass the id of this DIV's section down so that we can
         omit that section from the TOC -->
    <s:with-param name="div-id" select="ancestor::h:section[1]/@id"/>
  </s:apply-templates>
</s:template>

<s:template match="h:nav[@id='TOC']"/>

<!-- Main -->

<s:template match="h:header">
  <s:copy>
    <s:apply-templates select="@*|node()"/>
  </s:copy>
  <s:text>&nl;</s:text>
</s:template>

<s:template match="/h:html">
  <html lang="en">
    <s:text>&nl;</s:text>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes"/>
      <s:text>&nl;</s:text>
      <title>
        <s:value-of select="h:body/h:header/h:h1[@class='title']"/>
        <s:if test="h:body/h:header/h:div[@class='subtitle']">
          <s:text>: </s:text>
          <s:value-of select="h:body/h:header/h:div[@class='subtitle']"/>
        </s:if>
      </title>
      <s:text>&nl;</s:text>
      <link rel="shortcut icon" href="/images/nanoduke.ico"/>
      <s:text>&nl;</s:text>
      <link rel="stylesheet" type="text/css" href="/page-serif.css"/>
      <s:if test="h:body//h:span[@class='math inline' or @class='math display']">
        <script src="{$mathjax-url}"/>
      </s:if>
      <s:if test="$head">
        <s:text>&nl;</s:text>
        <s:copy-of select="document($head)/head/*"/>
      </s:if>
    </head>
    <s:text>&nl;</s:text>
    <body>
      <article>
        <s:text>&nl;</s:text>
        <s:apply-templates select="h:body/*"/>
        <s:text>&nl;</s:text>
        <footer class="legal">
          <s:text>&nl;</s:text>
          <div>&copy; <s:value-of select="$year"/> Oracle Corporation and/or its affiliates</div>
          <s:text>&nl;</s:text>
          <div><a href="/legal/tou">Terms of Use</a>
          &dot; License: <a href="/legal/gplv2+ce.html">GPLv2</a>
          &dot; <a href="https://www.oracle.com/legal/privacy/index.html">Privacy</a>
          &dot; <a href="/legal/openjdk-trademark-notice.html">Trademarks</a></div>
          <s:text>&nl;</s:text>
          <div>
            <s:choose>
              <s:when test="'$remote' = unknown">
                <s:value-of select="$hash"/>
              </s:when>
              <s:otherwise>
                <a href="{$remote}/blob/{$hash}/{$file}">
                  <s:value-of select="$hash"/>
                </a>
              </s:otherwise>
            </s:choose>
            &dot; <time datetime="{$isotime}"><s:value-of select="$time"/></time>
          </div>
        </footer>
        <s:text>&nl;</s:text>
      </article>
    </body>
  </html>
</s:template>

</s:stylesheet>
