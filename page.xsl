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

<!-- Extract h2 and h4 elements with subtitle, author, and date -->

<s:template mode="header" match="*"/>

<s:template mode="header" match="h:section">
  <s:apply-templates mode="header" select="*"/>
</s:template>

<s:template mode="header" match="h:section[@class='level4 author']/h:h4">
  <s:text>&nl;</s:text>
  <div class="author"><s:apply-templates select="*|text()"/></div>
</s:template>

<s:template mode="header" match="h:section[@class='level4 date']/h:h4">
  <s:text>&nl;</s:text>
  <div class="date"><s:apply-templates select="*|text()"/></div>
</s:template>

<s:template mode="header" match="h:section[@class='level2 subtitle']/h:h2">
  <s:text>&nl;</s:text>
  <div class="subtitle"><s:apply-templates select="*|text()"/></div>
</s:template>

<s:template mode="header" match="h:section[@class='level1']/h:h1">
  <s:text>&nl;</s:text>
  <h1 class="title"><s:apply-templates select="*|text()"/></h1>
</s:template>

<!-- Extract any non-header text in the header sections -->

<s:template mode="non-header" match="h:h1|h:h2|h:h3|h:h4"/>

<s:template mode="non-header" match="@*|node()">
  <s:copy>
    <s:apply-templates mode="non-header" select="@*|node()"/>
  </s:copy>
</s:template>

<s:template mode="non-header" match="h:section">
  <s:apply-templates mode="non-header" select="*"/>
</s:template>

<s:template mode="non-header" match="h:section[@class='level1']">
  <s:apply-templates mode="non-header"
                     select="h:section[@class='level2 subtitle'
                                       or @class='level4 author'
                                       or @class='level4 date']"/>
</s:template>

<!-- Skip a subtitle, author, or date section in normal processing -->

<s:template match="h:body/h:section[@class='level1'][1]
                   /h:section[@class='level2 subtitle'
                              or @class='level4 author'
                              or @class='level4 date']"/>

<!-- Skip the leading H1 in normal processing -->

<s:template match="h:body/h:section[@class='level1'][1]
                   /*[position()=1 and name()='h1']"/>

<!-- Main -->

<s:template match="/h:html">
  <html>
    <s:text>&nl;</s:text>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes"/>
      <s:text>&nl;</s:text>
      <title>
        <s:value-of select="h:body/h:section[1]/h:h1[1]"/>
        <s:if test="h:body/h:section/h:section[@class='level2 subtitle']">
          <s:text>: </s:text>
          <s:value-of select="h:body/h:section/h:section[@class='level2 subtitle']/h:h2"/>
        </s:if>
      </title>
      <s:text>&nl;</s:text>
      <link rel="shortcut icon" href="/images/nanoduke.ico"/>
      <s:text>&nl;</s:text>
      <link rel="stylesheet" type="text/css" href="/page-serif.css"/>
      <s:if test="$head">
        <s:text>&nl;</s:text>
        <s:copy-of select="document($head)/head/*"/>
      </s:if>
    </head>
    <s:text>&nl;</s:text>
    <body>
      <article>
        <s:text>&nl;</s:text>
        <header>
          <s:apply-templates mode="header"
                             select="h:body//h:section[@class='level1'][1]"/>
        </header>
        <s:text>&nl;</s:text>
        <s:apply-templates mode="non-header" select="h:body/h:section[1]"/>
        <s:apply-templates select="h:body/h:section[@class='level1'][1]/*"/>
        <s:text>&nl;</s:text>
        <footer class="legal">
          <s:text>&nl;</s:text>
          <div>&copy; <s:value-of select="$year"/> Oracle Corporation and/or its affiliates</div>
          <s:text>&nl;</s:text>
          <div><a href="/tou">Terms of Use</a>
          &dot; License: <a href="https://openjdk.java.net/legal/gplv2+ce.html">GPLv2</a>
          &dot; <a href="https://www.oracle.com/legal/privacy/index.html">Privacy</a>
          &dot; <a href="https://www.oracle.com/legal/trademarks.html">Trademarks</a></div>
          <s:text>&nl;</s:text>
          <div>
            <s:choose>
              <s:when test="'$remote' = unknown">
                <s:value-of select="$hash"/>
              </s:when>
              <s:otherwise>
                <a href="{$remote}/commits/{$branch}/{$file}">
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
