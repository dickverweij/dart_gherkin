import 'package:gherkin/src/gherkin/exceptions/syntax_error.dart';
import 'package:gherkin/src/gherkin/models/table.dart';
import 'package:gherkin/src/gherkin/runnables/debug_information.dart';
import 'package:gherkin/src/gherkin/runnables/multi_line_string.dart';
import 'package:gherkin/src/gherkin/runnables/runnable.dart';
import 'package:gherkin/src/gherkin/runnables/runnable_block.dart';
import 'package:gherkin/src/gherkin/runnables/table.dart';

class StepRunnable extends RunnableBlock {
  String _name;
  String? description;
  GherkinTable? table;
  List<String> multilineStrings = <String>[];

  StepRunnable(this._name, RunnableDebugInformation debug) : super(debug);

  @override
  String get name => _name;

  @override
  void addChild(Runnable child) {
    switch (child.runtimeType) {
      case MultilineStringRunnable:
        multilineStrings
            .add((child as MultilineStringRunnable).lines.join('\n'));
        break;
      case TableRunnable:
        if (table != null) {
          throw GherkinSyntaxException(
            "Only a single table can be added to the step '$name'",
          );
        }

        table = (child as TableRunnable).toTable();
        break;
      default:
        throw Exception(
          "Unknown runnable child given to Step '${child.runtimeType}'",
        );
    }
  }

  void setStepParameter(String parameterName, String value) {
    _name = _name.replaceAll('<$parameterName>', value);
    table?.setStepParameter(parameterName, value);
    debug = debug.copyWith(
      lineNumber: debug.lineNumber,
      lineText: debug.lineText.replaceAll('<$parameterName>', value),
    );
  }

  StepRunnable clone() {
    final cloned = StepRunnable(_name, debug);
    cloned.multilineStrings = multilineStrings.map((s) => s).toList();
    cloned.table = table?.clone();

    return cloned;
  }
}
