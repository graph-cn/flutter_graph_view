@REM  Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
@REM 
@REM  This source code is licensed under Apache 2.0 License.

flutter build web --dart-define=FLUTTER_WEB_USE_SKIA=true --no-tree-shake-icons  
move build/web ../docs
