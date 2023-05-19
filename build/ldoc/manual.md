# PRISM: A Comprehensive Roguelike Engine 

@lookup topics.md

## Overview 

PRISM is a versatile roguelike engine, built on the robust [Lua](https://www.lua.org/manual/5.1/) programming language. It offers an open-source, MIT-licensed platform for game development. Although its default interface is based on [Love](love2d.org), PRISM's core remains platform-agnostic, enabling smooth adaptation across any environment that supports Lua.

## Why Choose PRISM?

### Versatile Licensing:

Existing open-source roguelike engines like the [TEngine](https://te4.org/) (the powerhouse behind the acclaimed Tales of Maj’Eyal or ToME) come with GPL licenses, which might not be favorable for all commercial applications. PRISM stands out by providing a stable, feature-rich engine under the more flexible MIT license, appealing to a wider range of projects and use-cases.

### Adaptive Architecture:

PRISM's architecture promotes modularity, drawing significant inspiration from [Bob Nystrom's Roguelike Celebration Talk](https://www.youtube.com/watch?v=JxI3Eu5DPwE). 

In PRISM's game world, @{Actor}s, comprised of @{Component}s, serve as dynamic entities. @{Action}s drive the gameplay narrative. Actors reside within @{Level}s, the fundamental segments of the game world that also manage the main game loop. At the game's core is a while loop revolving around a scheduler, during which Actor's controller components generate Actions. Upon execution by the Level, these Actions can set off event listeners at both level-wide (@{System}s) and actor-wide (@{Condition}s) scales. The architecture cleverly blends elements of Entity Component System (ECS) and command pattern paradigms for greater flexibility and control.

### Accessibility:

PRISM's core, built atop Lua and Love, offers an approachable starting point for developing roguelike games, catering to beginners and experts alike with minimal learning curve. The inclusion of LuaJIT further enhances PRISM's performance, delivering exceptionally swift execution.

## Getting Started with PRISM

PRISM offers users two primary modules - 'core' and 'extra', which can be seamlessly integrated into their projects. These modules provide a suite of common utilities prevalent in nearly all roguelike games, such as vision, field of view, movement, inventory management, and more. The 'core' module contains essential elements found in nearly all roguelike games, while 'extra' brings additional features like lighting, attacking, and stats management — components that may not be required in all roguelike games or ones that you might want to customize.

In addition to these modules, PRISM also includes a fully functional open-source roguelike game as a real-world application example of the engine. This provides a practical template that you can freely customize, remix, and build upon according to your game development needs.