/*
  This file is part of Flow.

  Copyright (C) 2014 Sérgio Martins <iamsergio@gmail.com>

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "archivedtasksfiltermodel.h"
#include "taskstorage.h"

ArchivedTasksFilterModel::ArchivedTasksFilterModel(QAbstractItemModel *source,
                                                   QObject *parent)
    : QSortFilterProxyModel(parent)
    , m_archived(false)
{
    Q_ASSERT(source);
    setSourceModel(source);
    setAcceptArchived(true);
    connect(this, &ArchivedTasksFilterModel::rowsInserted,
            this, &ArchivedTasksFilterModel::countChanged);
    connect(this, &ArchivedTasksFilterModel::rowsRemoved,
            this, &ArchivedTasksFilterModel::countChanged);
    connect(this, &ArchivedTasksFilterModel::modelReset,
            this, &ArchivedTasksFilterModel::countChanged);
    connect(this, &ArchivedTasksFilterModel::layoutChanged,
            this, &ArchivedTasksFilterModel::countChanged);
}

void ArchivedTasksFilterModel::setAcceptArchived(bool accept)
{
    if (accept != m_archived) {
        m_archived = accept;
        invalidateFilter();

        if (m_archived) {
            setObjectName("ArchivedTasksFilterModel");
        } else {
            setObjectName("StagedTasksFilterModel");
        }
    }
}

bool ArchivedTasksFilterModel::filterAcceptsRow(int source_row,
                                                const QModelIndex &source_parent) const
{
    if (!sourceModel() || source_parent.isValid())
        return false;

    Task::Ptr task = sourceModel()->index(source_row, 0).data(TaskStorage::TaskPtrRole).value<Task::Ptr>();
    if (!task)
        return false;

    return m_archived ^ task->staged();
}

int ArchivedTasksFilterModel::count() const
{
    return rowCount();
}

void ArchivedTasksFilterModel::invalidateFilter()
{
    QSortFilterProxyModel::invalidateFilter();
}