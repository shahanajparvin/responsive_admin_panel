import 'dart:math';
import 'dart:ui';

import 'package:admin/models/RecentFile.dart';


import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lazy_data_table/lazy_data_table.dart';


import '../../../constants.dart';

class RecentFiles extends StatefulWidget {



   RecentFiles({
    Key? key,
  }) : super(key: key);

  @override
  State<RecentFiles> createState() => _RecentFilesState();
}

class _RecentFilesState extends State<RecentFiles> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recent Files",
            style: Theme.of(context).textTheme.titleMedium,
          ),

          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 500,
                child: LazyDataTable(
                  rows: demoRecentFiles.length,
                  columns: demoRecentFiles.length,
                  tableTheme: LazyDataTableTheme(
                      columnHeaderBorder:Border(bottom: BorderSide(color: Colors.grey, width: .5)),
                      cellBorder: Border(bottom: BorderSide(color: Colors.grey, width: .5)),
                      rowHeaderBorder: Border(bottom: BorderSide(color: Colors.grey, width: .5)),
                      cellColor: Colors.transparent,
                      columnHeaderColor: Colors.transparent,
                      cornerColor: Colors.transparent,
                      rowHeaderColor: Colors.transparent,
                      alternateRow: false,
                      alternateColumn: false),
                  topHeaderBuilder: (i) => Container(alignment: Alignment.centerLeft,  child: recentFileDataRow1(i,demoRecentFiles[i])),
                  leftHeaderBuilder: (i) => Center(child: recentFileDataRow1(i,demoRecentFiles[i])),
                  dataCellBuilder: (i, j) => Container(alignment: Alignment.centerLeft, child: dataCellBuilder(i,j+2)),
                  topLeftCornerWidget: Center(child: Text("Corner")),
                  tableDimensions: LazyDataTableDimensions(
                    leftHeaderWidth: leftColumnWidths.length==0?50:leftColumnWidths.values.fold(
                        double.negativeInfinity, (double max1, double value) => max(max1, value)),
                    customCellWidth: maxColumnWidths
                  ),
                ),
              ),

              if (!isLoading)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Adjust the sigma values for desired blur intensity
                  child: Container(
                    color: Colors.black, // Make the container transparent
                  ),
                ),
              ),
              // Loading indicator
              if (!isLoading)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),

        /*  SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              sortAscending: true,
              sortColumnIndex: 3,

              columns: [
            DataColumn(
            label: Text("File Name"),
          ),
          DataColumn(
            label: Text("Date"),
          ),
          DataColumn(
            label: Text("Size"),
          ),
          DataColumn(
            label: Text("File Name"),
          ),
          DataColumn(
            label: Text("Date"),
          ),
          DataColumn(
            label: Text("Size"),
          ),
        ],
              rows: List.generate(
                demoRecentFiles.length,
                    (index) => recentFileDataRow(demoRecentFiles[index]),
              ),
            ),
          ),*/

          /*SizedBox(
            width: double.infinity,
            child: DataTable(
              columnSpacing: defaultPadding,
              // minWidth: 600,


              rows: List.generate(
                demoRecentFiles.length,
                (index) => recentFileDataRow(demoRecentFiles[index]),
              ),
            ),
          ),*/
        ],
      ),
    );
  }


  Map<int, double> calculateMaxColumnWidths(RecentFile file, int index, Map<int, double> maxColumnWidthsCheck) {
    double cellWidth = getTextWidth(getCellContent(file, index));
    maxColumnWidthsCheck[index] = cellWidth;
    return maxColumnWidthsCheck;
  }

  recentFileDataRow(RecentFile fileInfo) {
    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              SvgPicture.asset(
                fileInfo.icon!,
                height: 30,
                width: 30,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Text(fileInfo.title!),
              ),
            ],
          ),
        ),
        DataCell(Text(fileInfo.date!)),
        DataCell(Text(fileInfo.size!)),
        DataCell(
          Row(
            children: [
              SvgPicture.asset(
                fileInfo.icon!,
                height: 30,
                width: 30,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Text(fileInfo.title!),
              ),
            ],
          ),
        ),
        DataCell(Text(fileInfo.date!)),
        DataCell(Text(fileInfo.size!)),
      ],
    );
  }

  Widget recentFileDataRow1(int i,RecentFile fileInfo) {
    leftColumnWidths[i] =  getTextWidth(fileInfo.title!);
    print('----gg '+ leftColumnWidths[i].toString());
    return Text(fileInfo.title!);
  }


  Map<int, double> maxColumnWidths = {};
  Map<int, double> leftColumnWidths = {};

  Widget dataCellBuilder(int rowIndex, int columnIndex) {
    final file = demoRecentFiles[rowIndex];
    Map<int, double> maxColumnWidthsCheck = {};
    late Widget cellWidget;

    // Convert switch to if-else statements
    if (columnIndex == 2) {
      calculateMaxColumnWidths(file, columnIndex, maxColumnWidthsCheck);
      cellWidget = Text(file.date);
    } else if (columnIndex == 3) {
      calculateMaxColumnWidths(file, columnIndex, maxColumnWidthsCheck);
      cellWidget = Text(file.size);
    } else if (columnIndex == 4) {
      calculateMaxColumnWidths(file, columnIndex, maxColumnWidthsCheck);
      cellWidget = Padding(
        padding: const EdgeInsets.all(5),
        child: SvgPicture.asset(
          file.icon!,
          height: 30,
          width: 30,
        ),
      );
    } else if (columnIndex == 5) {
      calculateMaxColumnWidths(file, columnIndex, maxColumnWidthsCheck);
      cellWidget = Text(file.title1);
    } else if (columnIndex == 6) {
      calculateMaxColumnWidths(file, columnIndex, maxColumnWidthsCheck);
      cellWidget = Text(file.date1);
    } else if (columnIndex == 7) {
      double maxWidth = calculateMaxColumnWidths(file, columnIndex, maxColumnWidthsCheck).values.fold(
        double.negativeInfinity,
            (double max1, double value) => max(max1, value),
      );
      maxColumnWidths[rowIndex] = maxWidth;
      cellWidget = Text(file.size1);
    } else {
      cellWidget = SizedBox.shrink();

      // Check if the last row is being built
      if (rowIndex == demoRecentFiles.length - 1) {
        // This is the last row being built
        // You can set your flag or trigger any action here
        // For example:


        print('Last row is built! '  +rowIndex.toString());
        setState(() {
          isLoading  = true;
        });

      }
    }

    return cellWidget;
  }


  String getCellContent(RecentFile file, int columnIndex) {
    switch (columnIndex) {
      case 2:
        return file.date!;
      case 3:
        return file.size!;
      case 4:
        return file.icon1!;
      case 5:
        return file.title1!;
      case 6:
        return file.date1!;
      case 7:
        return file.size1!;
      default:
        return '';
    }
  }

  double getTextWidth(String text) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: 14.0)),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size.width  + 50;
  }
}





class RecentFiles1 extends StatelessWidget {
  RecentFiles1({Key? key}) : super(key: key);

  final Map<int, double> _leftColumnWidths = {};
  final Map<int, double> _maxColumnWidths = {};

  @override
  Widget build(BuildContext context) {
    _calculateWidths();

    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recent Files",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(
            height: 500,
            child: LazyDataTable(
              rows: demoRecentFiles.length,
              columns: 8,
              tableTheme: LazyDataTableTheme(
                cellColor: Colors.black,
                cellBorder: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
              ),
              topHeaderBuilder: (i) => _headerCellBuilder(i),
              leftHeaderBuilder: (i) => _leftHeaderBuilder(i),
              dataCellBuilder: (i, j) => _dataCellBuilder(i, j + 2),
              topLeftCornerWidget: Center(child: Text("Corner")),
              tableDimensions: LazyDataTableDimensions(
                leftHeaderWidth: _leftColumnWidths.values.fold(0.0, max),
                customCellWidth: _maxColumnWidths,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _calculateWidths() {
    for (var i = 0; i < demoRecentFiles.length; i++) {
      final file = demoRecentFiles[i];
      _leftColumnWidths[i] = _getTextWidth(file.title!);

      _updateMaxColumnWidth(2, _getTextWidth(file.date!));
      _updateMaxColumnWidth(3, _getTextWidth(file.size!));
      _updateMaxColumnWidth(5, _getTextWidth(file.title1!));
      _updateMaxColumnWidth(6, _getTextWidth(file.date1!));
      _updateMaxColumnWidth(7, _getTextWidth(file.size1!));
    }
  }

  void _updateMaxColumnWidth(int columnIndex, double width) {
    if (!_maxColumnWidths.containsKey(columnIndex) || _maxColumnWidths[columnIndex]! < width) {
      _maxColumnWidths[columnIndex] = width;
    }
  }

  Widget _headerCellBuilder(int i) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Text(demoRecentFiles[i].title!),
    );
  }

  Widget _leftHeaderBuilder(int i) {
    return Center(
      child: Text(demoRecentFiles[i].title!),
    );
  }

  Widget _dataCellBuilder(int rowIndex, int columnIndex) {
    final file = demoRecentFiles[rowIndex];
    switch (columnIndex) {
      case 2:
        return Text(file.date!);
      case 3:
        return Text(file.size!);
      case 4:
        return Padding(
          padding: const EdgeInsets.all(5),
          child: SvgPicture.asset(
            file.icon!,
            height: 30,
            width: 30,
          ),
        );
      case 5:
        return Text(file.title1!);
      case 6:
        return Text(file.date1!);
      case 7:
        return Text(file.size1!);
      default:
        return SizedBox.shrink();
    }
  }

  double _getTextWidth(String text) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: 14.0)),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size.width + 50;
  }
}
