library lazy_data_table;



import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/scheduler.dart';



/// Create a lazily loaded data table.
///
/// The table is [columns] by [rows] big.
/// The [topHeaderBuilder], [leftHeaderBuilder], [rightHeaderBuiler] and [bottomHeaderBuilder] are optional,
/// and the corner widget should only be given if the two headers next to that corner are given.
class LazyDataTable extends StatefulWidget {
  LazyDataTable({
    Key? key,
    // Number of data columns.
    required this.columns,

    // Number of data rows.
    required this.rows,

    // Dimensions of the table elements.
    required this.tableDimensions,

    // Theme of the table elements.
    this.tableTheme = const LazyDataTableTheme(),

    // Builder function for the top header.
    this.topHeaderBuilder,

    // Builder function for the left header.
    this.leftHeaderBuilder,

    // Builder function for the right header.
    this.rightHeaderBuilder,

    // Builder function for the bottom header.
    this.bottomHeaderBuilder,

    // Builder function for the data cell.
    required this.dataCellBuilder,

    // Top left corner widget.
    this.topLeftCornerWidget,

    // Top right corner widget.
    this.topRightCornerWidget,

    // Bottom left corner widget.
    this.bottomLeftCornerWidget,

    // Bottom right corner widget.
    this.bottomRightCornerWidget,
  }) : super(key: key) {
    // Check for top left corner
    if (topHeaderBuilder == null || leftHeaderBuilder == null) {
      assert(topLeftCornerWidget == null,
      "The top left corner widget is only allowed when you have both the top header and the left header.");
    }
    // Check for top right corner
    if (topHeaderBuilder == null || rightHeaderBuilder == null) {
      assert(topRightCornerWidget == null,
      "The top right corner widget is only allowed when you have both the top header and the right header.");
    }
    // Check for bottom left corner
    if (bottomHeaderBuilder == null || leftHeaderBuilder == null) {
      assert(bottomLeftCornerWidget == null,
      "The bottom left corner widget is only allowed when you have both the bottom header and the left header.");
    }
    // Check for bottom right corner
    if (bottomHeaderBuilder == null || rightHeaderBuilder == null) {
      assert(bottomRightCornerWidget == null,
      "The bottom right corner widget is only allowed when you have both the bottom header and the right header.");
    }
  }

  /// The state class that contains the table.
  final table = _LazyDataTableState();

  // Amount of cells
  /// The number of columns in the table.
  final int columns;

  /// The number of rows in the table.
  final int rows;

  // Size of cells and headers
  /// The dimensions of the table cells and headers.
  final LazyDataTableDimensions tableDimensions;

  // Theme of the table
  /// The theme of the table cells and headers.
  final LazyDataTableTheme tableTheme;

  // Builder functions
  /// The builder function for a top header.
  final Widget Function(int columnIndex)? topHeaderBuilder;

  /// The builder function for a left header.
  final Widget Function(int rowIndex)? leftHeaderBuilder;

  /// The builder function for a right header.
  final Widget Function(int rowIndex)? rightHeaderBuilder;

  /// The builder function for a bottom header.
  final Widget Function(int columnIndex)? bottomHeaderBuilder;

  /// The builder function for a data cell.
  final Widget Function(int rowIndex, int columnIndex) dataCellBuilder;

  /// The widget for the top left corner.
  final Widget? topLeftCornerWidget;

  /// The widget for the top right corner.
  final Widget? topRightCornerWidget;

  /// The widget for the bottom left corner.
  final Widget? bottomLeftCornerWidget;

  /// The widget for the bottom right corner.
  final Widget? bottomRightCornerWidget;

  @override
  _LazyDataTableState createState() => table;

  /// Jump the table to the given cell.
  void jumpToCell(int column, int row) {
    table.jumpToCell(column, row);
  }

  /// Jump the table to the given location.
  void jumpTo(double x, double y) {
    table.jumpTo(x, y);
  }
}

class _LazyDataTableState extends State<LazyDataTable>
    with TickerProviderStateMixin {
  _CustomScrollController? _horizontalControllers;
  _CustomScrollController? _verticalControllers;

  @override
  void initState() {
    super.initState();
    _horizontalControllers = _CustomScrollController(this);
    _verticalControllers = _CustomScrollController(this);


  }

  @override
  void dispose() {
    _horizontalControllers!.dispose();
    _verticalControllers!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (pointerSignal) {if (pointerSignal is PointerScrollEvent) {
          jump(pointerSignal.scrollDelta.dx, pointerSignal.scrollDelta.dy);
        }
      },
      child: GestureDetector(
        onPanUpdate: (DragUpdateDetails details) {
          jump(-details.delta.dx, -details.delta.dy);
        },
        onPanEnd: (DragEndDetails details) {
          _verticalControllers!
              .setVelocity(-details.velocity.pixelsPerSecond.dy / 100);
          _horizontalControllers!
              .setVelocity(-details.velocity.pixelsPerSecond.dx / 100);
        },

        /// main container
        child: Row(
          children: <Widget>[
            // Left header
            widget.leftHeaderBuilder != null
                ? SizedBox(
              width: widget.tableDimensions.leftHeaderWidth,
              child: Column(
                children: <Widget>[
                  // Top left corner widget
                  widget.topLeftCornerWidget != null
                      ? SizedBox(
                    height: widget.tableDimensions.topHeaderHeight,
                    width: widget.tableDimensions.leftHeaderWidth,
                    child: Container(
                      decoration: widget.tableTheme.corner,
                      child: widget.topLeftCornerWidget,
                    ),
                  )
                      : Container(),
                  // Row headers
                  Expanded(
                    child: Scrollbar(
                      controller: _verticalControllers,
                      thumbVisibility: true,
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        controller: _verticalControllers,
                       // physics: NeverScrollableScrollPhysics(),
                        itemCount: widget.rows,
                        itemBuilder: (__, i) {
                          return Container(
                            height: widget
                                .tableDimensions.customCellHeight
                                .containsKey(i)
                                ? widget
                                .tableDimensions.customCellHeight[i]
                                : widget.tableDimensions.cellHeight,
                            width: widget.tableDimensions.leftHeaderWidth,
                            decoration: (widget.tableTheme.alternateRow &&
                                i % 2 != 0)
                                ? widget.tableTheme.alternateRowHeader
                                : widget.tableTheme.rowHeader,
                            child: widget.leftHeaderBuilder!(i),
                          );
                        }),
                  )),
                  // Bottom left corner widget
                  widget.bottomLeftCornerWidget != null
                      ? SizedBox(
                    height:
                    widget.tableDimensions.bottomHeaderHeight,
                    width: widget.tableDimensions.leftHeaderWidth,
                    child: Container(
                      decoration: widget.tableTheme.corner,
                      child: widget.bottomLeftCornerWidget,
                    ),
                  )
                      : Container(),
                ],
              ),
            )
                : Container(),
            Expanded(
              child: Column(
                children: <Widget>[
                  // Top headers
                  widget.topHeaderBuilder != null
                      ? SizedBox(
                    height: widget.tableDimensions.topHeaderHeight,
                    child: Scrollbar(
                      controller: _verticalControllers,
                      thumbVisibility: true,
                      child:  ListView.builder(
                          scrollDirection: Axis.horizontal,
                          controller: _horizontalControllers,
                        //  physics: NeverScrollableScrollPhysics(),
                          itemCount: widget.columns,
                          itemBuilder: (__, i) {
                            return Container(
                              height:
                              widget.tableDimensions.topHeaderHeight,
                              width: widget.tableDimensions.customCellWidth
                                  .containsKey(i)
                                  ? widget
                                  .tableDimensions.customCellWidth[i]
                                  : widget.tableDimensions.cellWidth,
                              decoration: (widget
                                  .tableTheme.alternateColumn &&
                                  i % 2 != 0)
                                  ? widget.tableTheme.alternateColumnHeader
                                  : widget.tableTheme.columnHeader,
                              child: widget.topHeaderBuilder!(i),
                            );
                          }),
                    ),
                  )
                      : Container(),
                  // Main data
                  Expanded(
                    child: Scrollbar(
                     // controller: _verticalControllers,
                      thumbVisibility: true,
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                       // controller: _verticalControllers,
                        itemCount: widget.rows,
                        physics: ClampingScrollPhysics(),
                        //primary: true, // Set this to true for the vertical scroll view// Allow scrolling
                        itemBuilder: (_, i) {
                          return SizedBox(
                            height: widget.tableDimensions.customCellHeight.containsKey(i)
                                ? widget.tableDimensions.customCellHeight[i]
                                : widget.tableDimensions.cellHeight,
                            child: Scrollbar(
                              controller: _horizontalControllers,
                              thumbVisibility: true,
                              child: ListView.builder(
                                physics: ClampingScrollPhysics(), // Allow scrolling
                                scrollDirection: Axis.horizontal,
                                controller: _horizontalControllers,
                                itemCount: widget.columns,
                               // primary: true, // Set this to true for the vertical scroll view
                                itemBuilder: (__, j) {
                                  return Container(
                                    height: widget.tableDimensions.customCellHeight.containsKey(i)
                                        ? widget.tableDimensions.customCellHeight[i]
                                        : widget.tableDimensions.cellHeight,
                                    width: widget.tableDimensions.customCellWidth.containsKey(j)
                                        ? widget.tableDimensions.customCellWidth[j]
                                        : widget.tableDimensions.cellWidth,
                                    decoration: (widget.tableTheme.alternateRow && i % 2 != 0) ||
                                        (widget.tableTheme.alternateColumn && j % 2 != 0)
                                        ? widget.tableTheme.alternateCell
                                        : widget.tableTheme.cell,
                                    child: widget.dataCellBuilder(i, j),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Bottom header
                  widget.bottomHeaderBuilder != null
                      ? SizedBox(
                    height: widget.tableDimensions.bottomHeaderHeight,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        controller: _horizontalControllers,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: widget.columns,
                        itemBuilder: (__, i) {
                          return Container(
                            height:
                            widget.tableDimensions.bottomHeaderHeight,
                            width: widget.tableDimensions.customCellWidth
                                .containsKey(i)
                                ? widget
                                .tableDimensions.customCellWidth[i]
                                : widget.tableDimensions.cellWidth,
                            decoration: (widget
                                .tableTheme.alternateColumn &&
                                i % 2 != 0)
                                ? widget.tableTheme.alternateColumnHeader
                                : widget.tableTheme.columnHeader,
                            child: widget.bottomHeaderBuilder!(i),
                          );
                        }),
                  )
                      : Container(),
                ],
              ),
            ),
            // Right header
            widget.rightHeaderBuilder != null
                ? SizedBox(
              width: widget.tableDimensions.rightHeaderWidth,
              child: Column(
                children: [
                  // Top left corner
                  widget.topRightCornerWidget != null
                      ? SizedBox(
                    height: widget.tableDimensions.topHeaderHeight,
                    width: widget.tableDimensions.rightHeaderWidth,
                    child: Container(
                      decoration: widget.tableTheme.corner,
                      child: widget.topRightCornerWidget,
                    ),
                  )
                      : Container(),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      controller: _verticalControllers,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: widget.rows,
                      itemBuilder: (__, i) {
                        return Container(
                          height: widget.tableDimensions.customCellHeight
                              .containsKey(i)
                              ? widget.tableDimensions.customCellHeight[i]
                              : widget.tableDimensions.cellHeight,
                          width: widget.tableDimensions.rightHeaderWidth,
                          decoration: (widget.tableTheme.alternateRow &&
                              i % 2 != 0)
                              ? widget.tableTheme.alternateRowHeader
                              : widget.tableTheme.rowHeader,
                          child: widget.rightHeaderBuilder!(i),
                        );
                      },
                    ),
                  ),
                  // Bottom right corner widget
                  widget.bottomRightCornerWidget != null
                      ? SizedBox(
                    height:
                    widget.tableDimensions.bottomHeaderHeight,
                    width: widget.tableDimensions.rightHeaderWidth,
                    child: Container(
                      decoration: widget.tableTheme.corner,
                      child: widget.bottomRightCornerWidget,
                    ),
                  )
                      : Container(),
                ],
              ),
            )
                : Container()
          ],
        ),
      ),
    );
  }

  /// Jump the table to the given cell.
  void jumpToCell(int column, int row) {
    double customWidth = 0;
    int customWidthCells = 0;
    for (int i = 0; i < column; i++) {
      if (widget.tableDimensions.customCellWidth.containsKey(i)) {
        customWidth += widget.tableDimensions.customCellWidth[i]!;
        customWidthCells++;
      }
    }
    _horizontalControllers!.jumpTo(
        (column - customWidthCells) * widget.tableDimensions.cellWidth +
            customWidth);

    double customHeight = 0;
    int customHeightCells = 0;
    for (int i = 0; i < column; i++) {
      if (widget.tableDimensions.customCellHeight.containsKey(i)) {
        customHeight += widget.tableDimensions.customCellHeight[i]!;
        customHeightCells++;
      }
    }
    _verticalControllers!.jumpTo(
        (row - customHeightCells) * widget.tableDimensions.cellHeight +
            customHeight);
  }

  /// Jump the table to the given location.
  void jumpTo(double x, double y) {
    _horizontalControllers!.jumpTo(x);
    _verticalControllers!.jumpTo(y);
  }

  /// Jump to a relative location from the current location.
  void jump(double x, double y) {
    _horizontalControllers!.jump(x);
    _verticalControllers!.jump(y);
  }
}

/// A custom synchronized scroll controller.
///
/// This controller stores all their attached [ScrollPosition] in a list,
/// and when given a notification via [processNotification], it will scroll
/// every ScrollPosition in that list to the same [offset].
class _CustomScrollController extends ScrollController {
  _CustomScrollController(TickerProvider provider) : super() {
    _ticker = provider.createTicker((_) {
      jumpTo(offset + _velocity);
      _velocity *= 0.9;
      if (_velocity < 0.1 && _velocity > -0.1) {
        _ticker.stop();
      }
    });
  }

  /// List of [ScrollPosition].
  List<ScrollPosition> _positions = [];

  /// The offset of the ScrollPositions.
  double offset = 0;

  /// Ticker to calculate the [_velocity].
  late Ticker _ticker;

  /// The velocity of the controller.
  /// The [_ticker] will tick while the velocity
  /// is not between -0.1 and 0.1.
  late double _velocity;

  /// Stores given [ScrollPosition] in the list and
  /// set the initial offset of that ScrollPosition.
  @override
  void attach(ScrollPosition position) {
    position.correctPixels(offset);
    _positions.add(position);
  }

  /// Removes given [ScrollPostion] from the list.
  @override
  void detach(ScrollPosition position) {
    _positions.remove(position);
  }

  /// Processes notification from one of the [ScrollPositions] in the list.
  void processNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      jumpTo(notification.metrics.pixels);
    }
  }

  /// Jumps every item in the list to the given [value],
  /// except the ones that are already at the correct offset.
  @override
  void jumpTo(double value) {
    if (value > _positions[0].maxScrollExtent) {
      offset = _positions[0].maxScrollExtent;
    } else if (value < 0) {
      offset = 0;
    } else {
      offset = value;
    }
    for (ScrollPosition position in _positions) {
      if (position.pixels != offset) {
        position.jumpTo(offset);
      }
    }
  }

  /// Jump to [offset] + [value].
  void jump(double value) {
    jumpTo(offset + value);
  }

  /// Set [_velocity] to new value.
  void setVelocity(double velocity) {
    if (_ticker.isActive) _ticker.stop();
    _velocity = velocity;
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}




/// Data class for the theme of a [LazyDataTable].
class LazyDataTableTheme {
  const LazyDataTableTheme({
    this.columnHeaderBorder =
    const Border.fromBorderSide(BorderSide(color: Colors.black)),
    this.columnHeaderColor = Colors.lightBlue,
    this.alternateColumnHeaderBorder =
    const Border.fromBorderSide(BorderSide(color: Colors.black)),
    this.alternateColumnHeaderColor = Colors.lightBlue,
    this.rowHeaderBorder =
    const Border.fromBorderSide(BorderSide(color: Colors.black)),
    this.rowHeaderColor = Colors.lightBlue,
    this.alternateRowHeaderBorder =
    const Border.fromBorderSide(BorderSide(color: Colors.black)),
    this.alternateRowHeaderColor = Colors.lightBlue,
    this.cellBorder =
    const Border.fromBorderSide(BorderSide(color: Colors.black)),
    this.cellColor = Colors.white,
    this.alternateCellBorder =
    const Border.fromBorderSide(BorderSide(color: Colors.black)),
    this.alternateCellColor = const Color(0xFFF5F5F5),
    this.cornerBorder =
    const Border.fromBorderSide(BorderSide(color: Colors.black)),
    this.cornerColor = Colors.blue,
    this.alternateRow = true,
    this.alternateColumn = false,
  });

  /// [BoxBorder] for the column header.
  final BoxBorder columnHeaderBorder;

  /// [Color] for the column header.
  final Color columnHeaderColor;

  /// A [BoxDecoration] containing the column header border and color.
  BoxDecoration get columnHeader =>
      BoxDecoration(border: columnHeaderBorder, color: columnHeaderColor);

  /// [BoxBorder] for the alternate column header.
  final BoxBorder alternateColumnHeaderBorder;

  /// [Color] for the alternate column header.
  final Color alternateColumnHeaderColor;

  /// A [BoxDecoration] containing the column header border and color.
  BoxDecoration get alternateColumnHeader => BoxDecoration(
      border: alternateColumnHeaderBorder, color: alternateColumnHeaderColor);

  /// [BoxBorder] for the row header.
  final BoxBorder rowHeaderBorder;

  /// [Color] for the row header.
  final Color rowHeaderColor;

  /// A [BoxDecoration] containing the row header border and color.
  BoxDecoration get rowHeader =>
      BoxDecoration(border: rowHeaderBorder, color: rowHeaderColor);

  /// [BoxBorder] for the alternate row header.
  final BoxBorder alternateRowHeaderBorder;

  /// [Color] for the alternate row header.
  final Color alternateRowHeaderColor;

  /// A [BoxDecoration] containing the row header border and color.
  BoxDecoration get alternateRowHeader => BoxDecoration(
      border: alternateRowHeaderBorder, color: alternateRowHeaderColor);

  /// [BoxBorder] for the cell.
  final BoxBorder cellBorder;

  /// [Color] for the cell.
  final Color cellColor;

  /// A [BoxDecoration] containing the cell border and color.
  BoxDecoration get cell => BoxDecoration(border: cellBorder, color: cellColor);

  /// [BoxBorder] for the alternate cell.
  final BoxBorder alternateCellBorder;

  /// [Color] for the alternate cell.
  final Color alternateCellColor;

  /// A [BoxDecoration] containing the alternate cell border and color.
  BoxDecoration get alternateCell =>
      BoxDecoration(border: alternateCellBorder, color: alternateCellColor);

  /// [BoxBorder] for the corner widget.
  final BoxBorder cornerBorder;

  /// [Color] for the corner widget.
  final Color cornerColor;

  /// A [BoxDecoration] containing the corner border and color.
  BoxDecoration get corner =>
      BoxDecoration(border: cornerBorder, color: cornerColor);

  /// Whether or not even rows should have an alternate theme.
  final bool alternateRow;

  /// Whether or not even columns should have an alternate theme.
  final bool alternateColumn;
}


/// Data class for the dimensions of a [LazyDataTable].
class LazyDataTableDimensions {
   LazyDataTableDimensions({
    this.cellHeight = 50,
    this.cellWidth = 200,
    this.topHeaderHeight = 50,
    this.leftHeaderWidth = 50,
    this.rightHeaderWidth = 50,
    this.bottomHeaderHeight = 50,
    this.customCellHeight = const {},
    this.customCellWidth = const {},
  });

  /// Height of a cell and row header.
  final double cellHeight;

  /// Width of a cell and column header.
  final double cellWidth;

  /// Height of a top header.
  final double topHeaderHeight;

  /// Width of a left header.
  final double leftHeaderWidth;

  /// Width of a right header.
  final double rightHeaderWidth;

  /// Height of a bottom header.
  final double bottomHeaderHeight;

  /// Map with the custom height for a certain rows.
  final Map<int, double> customCellHeight;

  /// Map with the custom width for certain columns.
  final Map<int, double> customCellWidth;

  final Map<int, double> measuredCellWidths = {};



  final Map<int, double> columnMaxWidths =  {};

  double getCellWidth(int columnIndex, String text, TextStyle style) {
    if (measuredCellWidths.containsKey(columnIndex)) {
      return measuredCellWidths[columnIndex]!;
    }
    final double textWidth = getTextWidth(text, style);
    final double cellWidth = textWidth + 16; // Add some padding
    print('=====columnIndex '+ columnIndex.toString());
    // Update the maximum width for this column
    columnMaxWidths[columnIndex] = max(cellWidth, columnMaxWidths[columnIndex] ?? 0);
    print('-------columnMaxWidths '+ columnMaxWidths.toString());
    measuredCellWidths[columnIndex] = columnMaxWidths[columnIndex]!;
    return columnMaxWidths[columnIndex]!;
  }

  double getTextWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text.trim(), style: style), // Trim whitespace
      textDirection: TextDirection.ltr, // Set the text direction
      maxLines: 1, // Limit to a single line
    )..layout();

    print('-----textPainter.size.width'+textPainter.size.width.toString());
    return textPainter.size.width;
  }

}








/*
library lazy_data_table;

import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/scheduler.dart';



/// Create a lazily loaded data table.
///
/// The table is [columns] by [rows] big.
/// The [topHeaderBuilder], [leftHeaderBuilder], [rightHeaderBuiler] and [bottomHeaderBuilder] are optional,
/// and the corner widget should only be given if the two headers next to that corner are given.
class LazyDataTable extends StatefulWidget {
  LazyDataTable({
    Key? key,
    // Number of data columns.
    required this.columns,

    // Number of data rows.
    required this.rows,

    // Dimensions of the table elements.
    required this.tableDimensions,

    // Theme of the table elements.
    this.tableTheme = const LazyDataTableTheme(),

    // Builder function for the top header.
    this.topHeaderBuilder,

    // Builder function for the left header.
    this.leftHeaderBuilder,

    // Builder function for the right header.
    this.rightHeaderBuilder,

    // Builder function for the bottom header.
    this.bottomHeaderBuilder,

    // Builder function for the data cell.
    required this.dataCellBuilder,

    // Top left corner widget.
    this.topLeftCornerWidget,

    // Top right corner widget.
    this.topRightCornerWidget,

    // Bottom left corner widget.
    this.bottomLeftCornerWidget,

    // Bottom right corner widget.
    this.bottomRightCornerWidget,
  }) : super(key: key) {
    // Check for top left corner
    if (topHeaderBuilder == null || leftHeaderBuilder == null) {
      assert(topLeftCornerWidget == null,
      "The top left corner widget is only allowed when you have both the top header and the left header.");
    }
    // Check for top right corner
    if (topHeaderBuilder == null || rightHeaderBuilder == null) {
      assert(topRightCornerWidget == null,
      "The top right corner widget is only allowed when you have both the top header and the right header.");
    }
    // Check for bottom left corner
    if (bottomHeaderBuilder == null || leftHeaderBuilder == null) {
      assert(bottomLeftCornerWidget == null,
      "The bottom left corner widget is only allowed when you have both the bottom header and the left header.");
    }
    // Check for bottom right corner
    if (bottomHeaderBuilder == null || rightHeaderBuilder == null) {
      assert(bottomRightCornerWidget == null,
      "The bottom right corner widget is only allowed when you have both the bottom header and the right header.");
    }
  }

  /// The state class that contains the table.
  final table = _LazyDataTableState();

  // Amount of cells
  /// The number of columns in the table.
  final int columns;

  /// The number of rows in the table.
  final int rows;

  // Size of cells and headers
  /// The dimensions of the table cells and headers.
  final LazyDataTableDimensions tableDimensions;

  // Theme of the table
  /// The theme of the table cells and headers.
  final LazyDataTableTheme tableTheme;

  // Builder functions
  /// The builder function for a top header.
  final Widget Function(int columnIndex)? topHeaderBuilder;

  /// The builder function for a left header.
  final Widget Function(int rowIndex)? leftHeaderBuilder;

  /// The builder function for a right header.
  final Widget Function(int rowIndex)? rightHeaderBuilder;

  /// The builder function for a bottom header.
  final Widget Function(int columnIndex)? bottomHeaderBuilder;

  /// The builder function for a data cell.
  final Widget Function(int rowIndex, int columnIndex) dataCellBuilder;

  /// The widget for the top left corner.
  final Widget? topLeftCornerWidget;

  /// The widget for the top right corner.
  final Widget? topRightCornerWidget;

  /// The widget for the bottom left corner.
  final Widget? bottomLeftCornerWidget;

  /// The widget for the bottom right corner.
  final Widget? bottomRightCornerWidget;


  @override
  _LazyDataTableState createState() => table;

  /// Jump the table to the given cell.
  void jumpToCell(int column, int row) {
    table.jumpToCell(column, row);
  }

  /// Jump the table to the given location.
  void jumpTo(double x, double y) {
    table.jumpTo(x, y);
  }
}

class _LazyDataTableState extends State<LazyDataTable>
    with TickerProviderStateMixin {
  _CustomScrollController? _horizontalControllers;
  _CustomScrollController? _verticalControllers;
  bool isLoad = false;

  @override
  void initState() {
    super.initState();

    _horizontalControllers = _CustomScrollController(this);
    _verticalControllers = _CustomScrollController(this);

    Future.delayed(const Duration(milliseconds: 500), () {
     print('------------ddddd');
// Here you can write your code

    */
/*  setState(() {
        // Here you can write your code for open new view
      });*//*


    });
  }

  @override
  void dispose() {
    _horizontalControllers!.dispose();
    _verticalControllers!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = DefaultTextStyle.of(context).style;
    return Listener(
        onPointerSignal: (pointerSignal) {
          if (pointerSignal is PointerScrollEvent) {
            jump(pointerSignal.scrollDelta.dx, pointerSignal.scrollDelta.dy);
          }
        },
        child: GestureDetector(
            onPanUpdate: (DragUpdateDetails details) {
              jump(-details.delta.dx, -details.delta.dy);
            },
            onPanEnd: (DragEndDetails details) {
              _verticalControllers!
                  .setVelocity(-details.velocity.pixelsPerSecond.dy / 100);
              _horizontalControllers!
                  .setVelocity(-details.velocity.pixelsPerSecond.dx / 100);
            },
            child: Row(
              children: <Widget>[
            widget.leftHeaderBuilder != null
            ? SizedBox(
              width: widget.tableDimensions.leftHeaderWidth,
              child: Column(
                children: <Widget>[
                  widget.topLeftCornerWidget != null
                      ? SizedBox(
                    height: widget.tableDimensions.topHeaderHeight,
                    width: widget.tableDimensions.leftHeaderWidth,
                    child: Container(
                      decoration: widget.tableTheme.corner,
                      child: widget.topLeftCornerWidget,
                    ),
                  )
                      : Container(),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      controller: _verticalControllers,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: widget.rows,
                      itemBuilder: (__, i) {
                        return Container(
                          height: widget.tableDimensions.customCellHeight
                              .containsKey(i)
                              ? widget.tableDimensions.customCellHeight[i]
                              : widget.tableDimensions.cellHeight,
                          width: widget.tableDimensions.leftHeaderWidth,
                          decoration: (widget.tableTheme.alternateRow &&
                              i % 2 != 0)
                              ? widget.tableTheme.alternateRowHeader
                              : widget.tableTheme.rowHeader,
                          child: widget.leftHeaderBuilder!(i),
                        );
                      },
                    ),
                  ),
                  widget.bottomLeftCornerWidget != null
                      ? SizedBox(
                    height: widget.tableDimensions.bottomHeaderHeight,
                    width: widget.tableDimensions.leftHeaderWidth,
                    child: Container(
                      decoration: widget.tableTheme.corner,
                      child: widget.bottomLeftCornerWidget,
                    ),
                  )
                      : Container(),
                ],
              ),
            )
                : Container(),
        Expanded(
          child: Column(
            children: <Widget>[
              widget.topHeaderBuilder != null
                  ? SizedBox(
                height: widget.tableDimensions.topHeaderHeight,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  controller: _horizontalControllers,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: widget.columns,
                  itemBuilder: (__, i) {
                    print('----hjhj'+widget.tableDimensions.columnMaxWidths[i].toString());
                    return Container(
                      height: widget.tableDimensions.topHeaderHeight,
                      width: widget.tableDimensions.columnMaxWidths[i], // Use the maximum width
                      decoration: (widget.tableTheme.alternateColumn && i % 2 != 0)
                          ? widget.tableTheme.alternateColumnHeader
                          : widget.tableTheme.columnHeader,
                      child: widget.topHeaderBuilder!(i),
                    );
                  },
                ),
              )
                  : Container(),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  controller: _verticalControllers,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: widget.rows,
                  itemBuilder: (_, i) {
                    if (i == widget.rows - 1) {

                    }
                    return SizedBox(
                      height: widget.tableDimensions.customCellHeight
                          .containsKey(i)
                          ? widget.tableDimensions.customCellHeight[i]
                          : widget.tableDimensions.cellHeight,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        controller: _horizontalControllers,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: widget.columns,
                        itemBuilder: (__, j) {
                          final String cellText =
                          widget.dataCellBuilder(i, j).toString();
                          return Container(
                            height: widget.tableDimensions.customCellHeight
                                .containsKey(i)
                                ? widget.tableDimensions.customCellHeight[i]
                                : widget.tableDimensions.cellHeight,
                            width: widget.tableDimensions.getCellWidth(
                              j,
                              cellText,
                              textStyle,
                            ),
                            decoration: (widget.tableTheme.alternateRow &&
                                i % 2 != 0) ||
                                (widget.tableTheme.alternateColumn &&
                                    j % 2 != 0)
                                ? widget.tableTheme.alternateCell
                                : widget.tableTheme.cell,
                            child: Container(
                                alignment: Alignment.centerLeft,
                                child: widget.dataCellBuilder(i, j)),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              widget.bottomHeaderBuilder != null
                  ? SizedBox(
                height: widget.tableDimensions.bottomHeaderHeight,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  controller: _horizontalControllers,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: widget.columns,
                  itemBuilder: (__, i) {
                    return Container(
                      height: widget.tableDimensions.bottomHeaderHeight,
                      width: widget.tableDimensions.getCellWidth(
                        i,
                        widget.bottomHeaderBuilder!(i).toString(),
                        textStyle,
                      ),
                      decoration: (widget.tableTheme.alternateColumn &&
                          i % 2 != 0)
                          ? widget.tableTheme.alternateColumnHeader
                          : widget.tableTheme.columnHeader,
                      child: widget.bottomHeaderBuilder!(i),
                    );
                  },
                ),
              )
                  : Container(),
            ],
          ),
        ),
        widget.rightHeaderBuilder != null
            ? SizedBox(
            width: widget.tableDimensions.rightHeaderWidth,
            child: Column(
              children: [
                widget.topRightCornerWidget != null
                    ? SizedBox(
                  height: widget.tableDimensions.topHeaderHeight,
                  width: widget.tableDimensions.rightHeaderWidth,
                  child: Container(
                    decoration: widget.tableTheme.corner,
                    child: widget.topRightCornerWidget,
                  ),
                )
                    : Container(),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    controller: _verticalControllers,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: widget.rows,
                    itemBuilder: (__, i) {
                      return Container(
                        height: widget.tableDimensions.customCellHeight
                            .containsKey(i)
                            ? widget.tableDimensions.customCellHeight[i]
                            : widget.tableDimensions.cellHeight,
                        width: widget.tableDimensions.rightHeaderWidth,
                        decoration: (widget.tableTheme.alternateRow &&
                            i % 2 != 0)
                            ? widget.tableTheme.alternateRowHeader
                            : widget.tableTheme.rowHeader,
                        child: widget.rightHeaderBuilder!(i),
                      );
                    },
                  ),
                ),
                widget.bottomRightCornerWidget != null
                    ? SizedBox(
                  height: widget.tableDimensions.bottomHeaderHeight,
                  width: widget.tableDimensions.rightHeaderWidth,
                  child: Container(
                    decoration: widget.tableTheme.corner,
                    child: widget.bottomRightCornerWidget,
                  ),
                )
                    : Container(),
              ],
            ),)
            : Container(),
              ],
            ),

        ),
    );
  }



  void _rebuildTopHeaderRow() {
    if (widget.topHeaderBuilder != null) {

      setState(() {

      });
    }
  }


            /// Jump the table to the given cell.
  void jumpToCell(int column, int row) {
    double customWidth = 0;
    int customWidthCells = 0;
    for (int i = 0; i < column; i++) {
      if (widget.tableDimensions.customCellWidth.containsKey(i)) {
        customWidth += widget.tableDimensions.customCellWidth[i]!;
        customWidthCells++;
      }
    }
    _horizontalControllers!.jumpTo(
        (column - customWidthCells) * widget.tableDimensions.defaultCellWidth +
            customWidth);

    double customHeight = 0;
    int customHeightCells = 0;
    for (int i = 0; i < column; i++) {
      if (widget.tableDimensions.customCellHeight.containsKey(i)) {
        customHeight += widget.tableDimensions.customCellHeight[i]!;
        customHeightCells++;
      }
    }
    _verticalControllers!.jumpTo(
        (row - customHeightCells) * widget.tableDimensions.cellHeight +
            customHeight);
  }

  /// Jump the table to the given location.
  void jumpTo(double x, double y) {
    _horizontalControllers!.jumpTo(x);
    _verticalControllers!.jumpTo(y);
  }

  /// Jump to a relative location from the current location.
  void jump(double x, double y) {
    _horizontalControllers!.jump(x);
    _verticalControllers!.jump(y);
  }
}

/// A custom synchronized scroll controller.
///
/// This controller stores all their attached [ScrollPosition] in a list,
/// and when given a notification via [processNotification], it will scroll
/// every ScrollPosition in that list to the same [offset].
class _CustomScrollController extends ScrollController {
  _CustomScrollController(TickerProvider provider) : super() {
    _ticker = provider.createTicker((_) {
      jumpTo(offset + _velocity);
      _velocity *= 0.9;
      if (_velocity < 0.1 && _velocity > -0.1) {
        _ticker.stop();
      }
    });
  }

  /// List of [ScrollPosition].
  List<ScrollPosition> _positions = [];

  /// The offset of the ScrollPositions.
  double offset = 0;

  /// Ticker to calculate the [_velocity].
  late Ticker _ticker;

  /// The velocity of the controller.
  /// The [_ticker] will tick while the velocity
  /// is not between -0.1 and 0.1.
  late double _velocity;

  /// Stores given [ScrollPosition] in the list and
  /// set the initial offset of that ScrollPosition.
  @override
  void attach(ScrollPosition position) {
    position.correctPixels(offset);
    _positions.add(position);
  }

  /// Removes given [ScrollPostion] from the list.
  @override
  void detach(ScrollPosition position) {
    _positions.remove(position);
  }

  /// Processes notification from one of the [ScrollPositions] in the list.
  void processNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      jumpTo(notification.metrics.pixels);
    }
  }

  /// Jumps every item in the list to the given [value],
  /// except the ones that are already at the correct offset.
  @override
  void jumpTo(double value) {
    if (value > _positions[0].maxScrollExtent) {
      offset = _positions[0].maxScrollExtent;
    } else if (value < 0) {
      offset = 0;
    } else {
      offset = value;
    }
    for (ScrollPosition position in _positions) {
      if (position.pixels != offset) {
        position.jumpTo(offset);
      }
    }
  }

  /// Jump to [offset] + [value].
  void jump(double value) {
    jumpTo(offset + value);
  }

  /// Set [_velocity] to new value.
  void setVelocity(double velocity) {
    if (_ticker.isActive) _ticker.stop();
    _velocity = velocity;
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}




/// Data class for the theme of a [LazyDataTable].
class LazyDataTableTheme {
  const LazyDataTableTheme({
    this.columnHeaderBorder =
    const Border.fromBorderSide(BorderSide(color: Colors.black)),
    this.columnHeaderColor = Colors.lightBlue,
    this.alternateColumnHeaderBorder =
    const Border.fromBorderSide(BorderSide(color: Colors.black)),
    this.alternateColumnHeaderColor = Colors.lightBlue,
    this.rowHeaderBorder =
    const Border.fromBorderSide(BorderSide(color: Colors.black)),
    this.rowHeaderColor = Colors.lightBlue,
    this.alternateRowHeaderBorder =
    const Border.fromBorderSide(BorderSide(color: Colors.black)),
    this.alternateRowHeaderColor = Colors.lightBlue,
    this.cellBorder =
    const Border.fromBorderSide(BorderSide(color: Colors.black)),
    this.cellColor = Colors.white,
    this.alternateCellBorder =
    const Border.fromBorderSide(BorderSide(color: Colors.black)),
    this.alternateCellColor = const Color(0xFFF5F5F5),
    this.cornerBorder =
    const Border.fromBorderSide(BorderSide(color: Colors.black)),
    this.cornerColor = Colors.blue,
    this.alternateRow = true,
    this.alternateColumn = false,
  });

  /// [BoxBorder] for the column header.
  final BoxBorder columnHeaderBorder;

  /// [Color] for the column header.
  final Color columnHeaderColor;

  /// A [BoxDecoration] containing the column header border and color.
  BoxDecoration get columnHeader =>
      BoxDecoration(border: columnHeaderBorder, color: columnHeaderColor);

  /// [BoxBorder] for the alternate column header.
  final BoxBorder alternateColumnHeaderBorder;

  /// [Color] for the alternate column header.
  final Color alternateColumnHeaderColor;

  /// A [BoxDecoration] containing the column header border and color.
  BoxDecoration get alternateColumnHeader => BoxDecoration(
      border: alternateColumnHeaderBorder, color: alternateColumnHeaderColor);

  /// [BoxBorder] for the row header.
  final BoxBorder rowHeaderBorder;

  /// [Color] for the row header.
  final Color rowHeaderColor;

  /// A [BoxDecoration] containing the row header border and color.
  BoxDecoration get rowHeader =>
      BoxDecoration(border: rowHeaderBorder, color: rowHeaderColor);

  /// [BoxBorder] for the alternate row header.
  final BoxBorder alternateRowHeaderBorder;

  /// [Color] for the alternate row header.
  final Color alternateRowHeaderColor;

  /// A [BoxDecoration] containing the row header border and color.
  BoxDecoration get alternateRowHeader => BoxDecoration(
      border: alternateRowHeaderBorder, color: alternateRowHeaderColor);

  /// [BoxBorder] for the cell.
  final BoxBorder cellBorder;

  /// [Color] for the cell.
  final Color cellColor;

  /// A [BoxDecoration] containing the cell border and color.
  BoxDecoration get cell => BoxDecoration(border: cellBorder, color: cellColor);

  /// [BoxBorder] for the alternate cell.
  final BoxBorder alternateCellBorder;

  /// [Color] for the alternate cell.
  final Color alternateCellColor;

  /// A [BoxDecoration] containing the alternate cell border and color.
  BoxDecoration get alternateCell =>
      BoxDecoration(border: alternateCellBorder, color: alternateCellColor);

  /// [BoxBorder] for the corner widget.
  final BoxBorder cornerBorder;

  /// [Color] for the corner widget.
  final Color cornerColor;

  /// A [BoxDecoration] containing the corner border and color.
  BoxDecoration get corner =>
      BoxDecoration(border: cornerBorder, color: cornerColor);

  /// Whether or not even rows should have an alternate theme.
  final bool alternateRow;

  /// Whether or not even columns should have an alternate theme.
  final bool alternateColumn;
}


/// Data class for the dimensions of a [LazyDataTable].
double getTextWidth(String text, TextStyle style) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text.trim(), style: style), // Trim whitespace
    textDirection: TextDirection.ltr, // Set the text direction
    maxLines: 1, // Limit to a single line
  )..layout();

   print('-----textPainter.size.width'+textPainter.size.width.toString());
  return textPainter.size.width;
}

class LazyDataTableDimensions {
   LazyDataTableDimensions({
    this.cellHeight = 50,
    this.defaultCellWidth = 0,
    this.topHeaderHeight = 50,
    this.leftHeaderWidth = 50,
    this.rightHeaderWidth = 50,
    this.bottomHeaderHeight = 50,
    this.customCellHeight = const {},
    this.customCellWidth = const {},

    this.measuredCellWidths = const {},
  });

  final double cellHeight;
  final double defaultCellWidth;
  final double topHeaderHeight;
  final double leftHeaderWidth;
  final double rightHeaderWidth;
  final double bottomHeaderHeight;
  final Map<int, double> customCellHeight;
  final Map<int, double> customCellWidth;

  final Map<int, double> measuredCellWidths;



  final Map<int, double> columnMaxWidths =  {};



  double getCellWidth(int columnIndex, String text, TextStyle style) {
    if (measuredCellWidths.containsKey(columnIndex)) {
      return measuredCellWidths[columnIndex]!;
    }
    final double textWidth = getTextWidth(text, style);
    final double cellWidth = textWidth + 16; // Add some padding
    print('=====columnIndex '+ columnIndex.toString());
    // Update the maximum width for this column
    columnMaxWidths[columnIndex] = max(cellWidth, columnMaxWidths[columnIndex] ?? 0);
    print('-------columnMaxWidths '+ columnMaxWidths.toString());
    return columnMaxWidths[columnIndex]!;
  }
}





*/
