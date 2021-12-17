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

<s:output method="xml"
  indent="no"
  encoding="utf-8"/>

<s:template match="@*|node()">
  <s:copy>
    <s:apply-templates select="@*|node()"/>
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

<!-- Skip header content in normal processing -->

<s:template match="h:section[(@class='level1' and position()=1)][1]/h:h1[1]
                   |h:section[@class='level2 subtitle']/h:h2
                   |h:section[@class='level4 author']/h:h4
                   |h:section[@class='level4 date']/h:h4"/>

<s:template match="h:section[(@class='level1' and position()=1)
                             or @class='level2 subtitle'
                             or @class='level4 author'
                             or @class='level4 date']">
  <s:apply-templates select="*"/>
</s:template>

<!-- Omit header content from TOC -->

<s:template mode="toc" match="@*|node()">
  <s:copy>
    <s:apply-templates mode="toc" select="@*|node()"/>
  </s:copy>
</s:template>

<s:template mode="toc" match="h:li">
  <s:variable name="id" select="substring(h:a[1]/@href,2)"/>
  <s:if test="not(//h:section[@id=$id]
                  /ancestor-or-self::h:section[@class='level2 subtitle'
                                               or @class='level4 author'
                                               or @class='level4 date'])">
    <s:copy>
      <s:apply-templates mode="toc" select="*"/>
    </s:copy>
  </s:if>
</s:template>

<s:template match="h:nav[@id='TOC']">
  <s:copy>
    <s:apply-templates mode="toc" select="@*|*"/>
  </s:copy>
</s:template>

<!-- While we're here, fix up figures to use their captions as image alt text
     rather than captions
  -->

<s:template match="h:figure[h:img and h:figcaption]">
  <figure>
    <img>
      <s:copy-of select="h:img/@*"/>
      <s:attribute name="alt"><s:value-of select="h:figcaption"/></s:attribute>
    </img>
  </figure>
</s:template>


<!-- Main -->

<s:template match="/h:html">
  <html>
    <body>
      <s:text>&nl;</s:text>
      <header>
        <s:apply-templates mode="header"
                           select="h:body/h:section[@class='level1'][1]"/>
      </header>
      <s:text>&nl;</s:text>
      <s:apply-templates select="h:body/*"/>
      <s:text>&nl;</s:text>
    </body>
  </html>
</s:template>

</s:stylesheet>
