<!-- 
  Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
  This source code is licensed under Apache 2.0 License.
 -->

# Overview

**Flutter Graph View** is a powerful Dart/Flutter library designed to create interactive and animated visualizations of graph data structures. It provides all the tools needed to render, layout, and interact with complex networks of nodes and edges in your Flutter applications.

Whether you're building organizational charts, knowledge graphs, social network visualizations, dependency diagrams, or any other graph-based UI, Flutter Graph View delivers smooth animations, responsive interaction, and extensive customization options.

## What is a Graph?

A graph is a fundamental data structure composed of:
- **Vertices (Nodes)**: Individual entities or data points that represent objects in your domain
- **Edges (Connections)**: Lines or links between vertices that represent relationships or dependencies between those entities

```
    [Vertex A] ─── [Vertex B]
          │              │
          └──────────────┘
```

In this simple example, Vertex A and Vertex B are connected by edges, forming a basic graph structure.

## Three-Layer Architecture

Flutter Graph View is organized into three cohesive layers that work together seamlessly:

### 1. **Data Layer** (`model/`)

Fundamental data structures that represent graph information:

- **`Graph<ID>`** — The container that holds all vertices, edges, and metadata. Acts as the central repository for your entire graph structure, managing collections, caches, and relationships.
- **`Vertex<ID>`** — Represents a single node in the graph with properties such as position, visual style (color, size), connections to other nodes, and associated business data.
- **`Edge`** — Represents a directed or undirected connection between two vertices with configurable properties like weight, ranking, type, and custom styling.

### 2. **Logic Layer** (`core/`)

Processing, computation, and transformation of graph data:

- **`DataConvertor`** — Transforms your business data (from JSON, REST APIs, databases, CSV, etc.) into the Graph, Vertex, and Edge models that the library understands. Handles data validation and mapping.
- **`GraphAlgorithm`** — Interface and implementations for layout algorithms (force-directed, circle, random) and decorator-based extensibility for advanced behaviors like physics simulation, persistence, and interaction handling.
- **`Options`** — Centralized configuration hub for behaviors, callbacks, event handlers, zoom/pan settings, scale ranges, and visual options. Acts as the main configuration object.
- **`GraphStyle`** — Manages all visual styling aspects including colors per tag, stroke widths, edge appearances, text styles, and rendering preferences.

### 3. **Presentation Layer** (`widgets/`)

Flutter widgets and rendering components that display the graph on screen:

- **`FlutterGraphWidget`** — The main widget you add to your Flutter app; orchestrates all layers and handles the UI lifecycle, state management, and widget composition.
- **`GraphComponentCanvas`** — A custom canvas widget that manages rendering, animation, and user input gestures (zoom, pan, tap detection, drag interactions).
- **`GraphPainter`** — The low-level painter that draws vertices and edges on the canvas using Dart's drawing APIs, handling per-frame rendering and visual updates.

```
┌─────────────────────────────────────────────────────────────────────┐
│        FlutterGraphWidget (Main Widget Entry Point)                 │
├─────────────────────────────────────────────────────────────────────┤
│  Presentation Layer                                                 │
│  - GraphComponentCanvas (canvas & input management)                 │
│  - GraphPainter (renders vertices & edges each frame)               │
├─────────────────────────────────────────────────────────────────────┤
│  Logic Layer                                                        │
│  - GraphAlgorithm (computes positions via layout logic)             │
│  - DataConvertor (transforms business data → Graph models)          │
│  - Options (centralized configuration)                              │
├─────────────────────────────────────────────────────────────────────┤
│  Data Layer                                                         │
│  - Graph, Vertex, Edge (core immutable/mutable models)              │
├─────────────────────────────────────────────────────────────────────┤
│  Your Business Data (JSON, API, Database, CSV, Objects, etc.)       │
└─────────────────────────────────────────────────────────────────────┘
```

## Processing Flow

Here's how data flows through the library from your input to the rendered graph:

1. **Input Data** — You provide your raw data (JSON, Map, objects, etc.) in any format your application uses.
2. **Conversion** — A `DataConvertor` validates and transforms your data into `Graph`, `Vertex`, and `Edge` models the library understands.
3. **Layout Computation** — A `GraphAlgorithm` (force-directed, circle, random, or custom) iteratively calculates optimal positions for each node based on the graph topology.
4. **Rendering** — The `GraphPainter` draws vertices and edges on the canvas at their computed positions, with colors, styles, and text from the configuration.
5. **User Interaction** — Mouse/touch events (hover, tap, drag, zoom, pan) trigger callbacks and update the graph state in real time.
6. **Animation** — Position changes and style updates animate smoothly across frames using Flutter's animation system.

```
Your Data → Converter → Graph Model → Algorithm Layout → Canvas Draw → Screen
                                               ↓
                       User Events: Hover, Tap, Drag, Zoom, Pan
                                               ↓
                       Callback Handlers → Update State → Re-render
```

## Key Features

### **Multiple Layout Algorithms**

- **Force Directed** — Simulates physical forces (attraction between connected nodes, repulsion between all pairs) for natural, organic layouts. Great for visualizing complex networks.
- **Circle Layout** — Positions nodes in a perfect circle around a center point. Useful for radial hierarchies or regular distributions.
- **Random Algorithm** — Places nodes randomly. Often used for testing or initial population of custom layouts.
- **Custom Algorithms** — Extend `GraphAlgorithm` to implement your own layout logic (treemap, Sankey, radial tree, etc.).

### **Complete Visual Customization**

- Custom vertex shapes (circle, diamond, rectangle, or fully custom shapes with bezier curves)
- Configurable colors per tag or by index with fallback mechanisms
- Customizable text rendering (size, style, color, font) per vertex or globally
- Edge decorators for special edge visual styles
- Per-vertex and global visual properties

### **Algorithm Decorators**

Extend layout algorithm behaviors modularly using the decorator pattern:

- **HookeDecorator** — Applies spring-like attraction forces between connected nodes
- **CoulombDecorator** — Applies electrostatic repulsion forces between all or nearby nodes
- **PauseDecorator** — Allows pausing/resuming layout computation with UI control
- **PersistenceDecorator** — Saves and restores layout state between sessions
- **PinDecorator** — Fixes specific nodes in place
- **PinCenterDecorator** — Anchors key nodes to the canvas center
- Custom decorators — Implement your own behavior extensions

### **Rich Interactivity**

- Automatic hover detection for nodes and edges
- Smooth zoom (mouse wheel / pinch) and pan (drag) with configurable limits
- Multi-node selection with visual feedback
- Floating data panels showing node/edge information
- Customizable event callbacks (tap down, tap up, tap cancel, drag, etc.)
- Visual feedback (opacity change, scaling, highlighting) for hover/selection states

### **Data Panels & Dashboard**

Display contextual information when users interact:

- **Vertex Panel** — Shows data when hovering over or tapping a node
- **Edge Panel** — Shows data when hovering over or clicking an edge
- **Custom Panels** — Define your own UI to display in overlays
- **Legend** — Display color coding and visual element meanings
- **Overlay Controls** — Add buttons, sliders, or custom widgets to the canvas edges

## Key Concepts

### **Position (Vector2)**

Each vertex is located at a 2D coordinate on the canvas:
```dart
vertex.position = Vector2(x, y); // Computed by the algorithm
```

### **Radius**

The visual size of a node can be static or dynamically calculated based on its degree (number of connections):
```dart
double get radius => (log(degree * 10 + 1)) + baseRadius;
```

### **Neighbors**

Each vertex maintains references to connected nodes for quick access:
```dart
List<Vertex> get neighbors => [...nextVertexes, ...prevVertexes];
```

### **Edges Between Two Vertices**

In multigraphs (multiple edges between the same pair of nodes), the system calculates different visual paths for each edge:
```dart
Map<String, List<Edge>> edgesBetweenHash; // Organizes edges by edge type
```

### **Tags and Styling**

Tags are labels that categorize vertices for styling and filtering:
```dart
vertex.tag = 'user';        // Primary tag
vertex.tags = ['user', 'admin']; // Additional tags
```

## Common Use Cases

### **Dependency & Impact Analysis**

Visualize module dependencies, software architecture, or how changes propagate through systems.

### **Process & Workflow Diagrams**

Display business processes, data pipelines, or execution flows with clear relationship visualization.

### **Object & Scene Graphs**

Represent complex data structures like game scene hierarchies, document trees, or knowledge bases.

### **Social Networks & Collaboration**

Show connections between people, teams, or communities in your organization or platform.

### **Scientific & Research Data**

Explore complex relationships in papers, citations, molecular structures, or research networks.

### **Organizational Hierarchies**

Display reporting structures, team relationships, and organizational change over time.

## Next Steps

- Read [Data Models](models.md) to understand the core structures that power the library
- Follow [Quick Start](quick_start.md) to create your first interactive graph in 5 minutes
- Explore [Layout Algorithms](algorithms.md) to understand and choose the best algorithm for your use case
- Configure [Styles](styles.md) to match your application's look and feel
- Learn about [Decorators](decorators.md) to add specialized behaviors

---

**Version:** 2.x | **License:** Apache 2.0 | **GitHub:** [flutter_graph_view](https://github.com/NoachDev/flutter_graph_view)
